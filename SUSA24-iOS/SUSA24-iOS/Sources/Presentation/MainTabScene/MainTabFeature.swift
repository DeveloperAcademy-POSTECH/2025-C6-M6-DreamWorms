//
//  MainTabFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct MainTabFeature: DWReducer {
    
    private let caseRepository: CaseRepositoryProtocol
    
    /// MainTabFeature를 초기화합니다.
    /// - Parameter caseRepository: 케이스 정보를 조회하는 Repository
    init(caseRepository: CaseRepositoryProtocol) {
        self.caseRepository = caseRepository
    }
    
    
    // MARK: - State
    
    /// 메인 탭 화면의 상태를 나타냅니다./
    struct State: DWState {
        /// 현재 표시 중인 케이스의 UUID
        var caseID: UUID
        
        /// 현재 케이스의 상세정보
        ///
        /// 'nil'인 경우 아직 로드 되지않았거나 로드에 실패 한 상태
        var caseInfo: Case?
        
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
        case loadCaseInfo(Case?)
        
        /// 탭을 선택하는 액션
        ///  - Parameter MainTabIndentifier: 선택할 탭의 식별자
        case selectTab(MainTabIdentifier)
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
            let caseId = state.caseID
            return .task {[caseRepository] in
                do {
                    let caseInfo = try await caseRepository.fetchCases(id: caseId)
                    return .loadCaseInfo(caseInfo)
                } catch {
                    return .loadCaseInfo(nil)
                }
            }
        case .loadCaseInfo(let caseInfo):
            state.caseInfo = caseInfo
            return .none
            
        case .selectTab(let tab):
            state.selectedTab = tab
            return .none
        }
    }
}
