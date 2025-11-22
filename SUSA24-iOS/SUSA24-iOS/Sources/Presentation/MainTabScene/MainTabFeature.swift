//
//  MainTabFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

/// 메인 탭 화면의 상태와 액션을 관리하는 Reducer입니다.
///
/// MainTabFeature는 Map, Dashboard, OnePage 탭 간의 전환을 관리하고,
/// 현재 선택된 케이스의 정보와 위치 데이터를 가져와 하위 Feature들에게 제공합니다.
///
/// ## Topics
///
/// ### State
/// - ``State``
///
/// ### Actions
/// - ``Action``

struct MainTabFeature: DWReducer {
    private let caseRepository: CaseRepositoryProtocol
    private let locationRepository: LocationRepositoryProtocol

    /// MainTabFeature를 초기화합니다.
    /// - Parameters:
    ///   - caseRepository: 케이스 정보를 조회하는 Repository
    ///   - locationRepository: Location 실시간 감지를 위한 Repository
    init(caseRepository: CaseRepositoryProtocol, locationRepository: LocationRepositoryProtocol) {
        self.caseRepository = caseRepository
        self.locationRepository = locationRepository
    }
    
    // MARK: - State
    
    /// 메인 탭 화면의 상태를 나타냅니다./
    struct State: DWState {
        /// 현재 표시 중인 케이스의 UUID
        var selectedCurrentCaseId: UUID
        
        /// 현재 케이스의 상세정보
        ///
        /// 'nil'인 경우 아직 로드 되지않았거나 로드에 실패 한 상태
        var caseInfo: Case?
        
        /// 현재 선택된 케이스의 로케이션 정보
        var locations: [Location] = []
        
        /// 현재 선택된 탭
        var selectedTab: MainTabIdentifier = .map
    }
    
    // MARK: - Action
    
    /// 메인 탭 화면에서 발생할 수 있는 액션
    enum Action: DWAction {
        /// 화면에 나타날때 발생하는 액션
        ///
        /// 케이스 정보를 DB에서 긁어옴
        case onAppear

        /// 케이스 정보를 로드하는 액션
        /// - Parameter Case?: 로드된 케이스 정보. 로드 실패 시 'nil'
        case loadCaseInfoDetail(case: Case?, locations: [Location])

        /// 탭을 선택하는 액션
        ///  - Parameter MainTabIndentifier: 선택할 탭의 식별자
        case selectTab(MainTabIdentifier)

        /// Location 실시간 감지 시작
        case startLocationObserver

        /// Location 실시간 감지 중지
        case stopLocationObserver

        /// Location 변경사항 수신
        /// - Parameter locations: 업데이트된 Location 배열
        case locationsUpdated([Location])
    }
    
    // MARK: - Reducer
    
    /// 액션을 받아 상태를 수정, 후속 Effect를 반환합니다.
    ///
    /// - Parameters:
    ///     - state: 수정할 상태
    ///     - action: 처리할 액션
    ///     - Returns: 후속 액션을 방출할 수 있는 Effect
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            let caseId = state.selectedCurrentCaseId
            let repository = caseRepository
            return .merge(
                // 초기 데이터 로드
                .task {
                    do {
                        let (caseInfo, locations) = try await repository.fetchAllDataOfSpecificCase(for: caseId)
                        return .loadCaseInfoDetail(case: caseInfo, locations: locations)
                    } catch {
                        return .loadCaseInfoDetail(case: nil, locations: [])
                    }
                },
                // 실시간 감지 시작
                .send(.startLocationObserver)
            )

        case let .loadCaseInfoDetail(caseInfo, locations):
            state.caseInfo = caseInfo
            state.locations = locations

            return .none

        case let .selectTab(tab):
            // 같은 탭을 다시 탭한 경우 (맵 탭만)
            if state.selectedTab == tab, tab == .map {
                NotificationCenter.default.post(name: .resetDetentToMid, object: nil)
            }
            state.selectedTab = tab
            return .none

        case .startLocationObserver:
            let caseId = state.selectedCurrentCaseId
            // AsyncStream에서 여러 액션을 연속으로 방출하기 위해 DWEffect init 직접 사용
            // downstream 클로저를 통해 CoreData 변경사항마다 .locationsUpdated 액션 방출
            return DWEffect { [locationRepository] downstream in
                // 1. viewContext는 MainActor에 격리되므로 MainActor에서 AsyncStream 생성
                let stream = await MainActor.run {
                    locationRepository.watchLocations(caseId: caseId)
                }

                // 2. AsyncStream은 값 타입(Sendable)이므로 여기서 iterate 가능
                for await locations in stream {
                    downstream(.locationsUpdated(locations))
                }

                // AsyncStream 종료 시 observer 정리 완료 신호
                downstream(.stopLocationObserver)
            }

        case .stopLocationObserver:
            return .none

        case let .locationsUpdated(locations):
            state.locations = locations
            return .none
        }
    }
}
