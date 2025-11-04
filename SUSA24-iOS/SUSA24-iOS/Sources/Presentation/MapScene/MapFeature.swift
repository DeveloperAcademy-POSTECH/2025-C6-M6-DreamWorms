//
//  MapFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

// MARK: - Reducer

/// 지도 화면의 상태와 액션을 관리하는 Reducer입니다.
struct MapFeature: DWReducer {
    
    private let repository: LocationRepositoryProtocol
    
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - State
    
    /// 지도 화면의 상태를 나타냅니다.
    struct State: DWState {
        /// 표시할 위치 데이터 배열입니다.
        var locations: [Location] = []
        /// 현재 선택된 케이스의 UUID입니다.
        var caseId: UUID?
        
        /// 기지국 범위 필터의 선택 상태입니다.
        var isBaseStationRangeSelected: Bool = false
        /// 누적 빈도 필터의 선택 상태입니다.
        var isVisitFrequencySelected: Bool = false
        /// 최근 기지국 필터의 선택 상태입니다.
        var isRecentBaseStationSelected: Bool = false
    }
    
    // MARK: - Action
    
    /// 지도 화면에서 발생할 수 있는 액션입니다.
    enum Action: DWAction {
        /// 화면이 나타날 때 발생하는 액션입니다.
        case onAppear
        /// 위치 데이터를 로드하는 액션입니다.
        /// - Parameter locations: 로드할 위치 데이터 배열
        case loadLocations([Location])
        /// 필터를 선택/해제하는 액션입니다.
        /// - Parameter filter: 선택할 필터 타입
        case selectFilter(MapFilterType)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            guard let caseId = state.caseId else { return .none }
            return .task { [repository] in
                do {
                    // NOTE: 테스트용 목데이터 저장 로직
                    // 케이스 선택 시 해당 케이스의 빈 문자열("") suspect에 Location 목데이터 저장
                    // 실제 데이터가 없을 경우를 대비한 테스트 데이터
                    // 프로토콜에는 포함되지 않으므로 타입 캐스팅 사용
                    if let locationRepository = repository as? LocationRepository {
                        try await locationRepository.loadMockDataIfNeeded(caseId: caseId)
                    }
                    
                    let locations = try await repository.fetchLocations(caseId: caseId)
                    return .loadLocations(locations)
                } catch {
                    return .none
                }
            }
            
        case .loadLocations(let locations):
            state.locations = locations
            return .none
            
        case .selectFilter(let filter):
            switch filter {
            case .cellStationRange:
                state.isBaseStationRangeSelected.toggle()
            case .visitFrequency:
                state.isVisitFrequencySelected.toggle()
            case .recentBaseStation:
                state.isRecentBaseStationSelected.toggle()
            }
            return .none
        }
    }
}

// MARK: - Map Filter Type

/// 지도 화면에서 사용하는 필터 타입입니다.
enum MapFilterType: String, CaseIterable {
    case cellStationRange = "기지국 범위"
    case visitFrequency = "누적 빈도"
    case recentBaseStation = "최근 기지국"
    
    var iconName: String {
        switch self {
        case .cellStationRange:
            return "icn_cell_range_filter"
        case .visitFrequency:
            return "icn_visit_frequency_filter"
        case .recentBaseStation:
            return "icn_cell_station_filter"
        }
    }
}
