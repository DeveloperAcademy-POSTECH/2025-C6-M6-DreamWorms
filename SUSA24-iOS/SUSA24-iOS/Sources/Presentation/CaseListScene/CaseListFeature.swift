//
//  CaseListFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import CoreData
import SwiftUI

enum CaseListPickerTab: CaseIterable {
    case allCase, shareCase
    var title: String {
        switch self {
        case .allCase: String(localized: .caseListAllCasePicker)
        case .shareCase: String(localized: .caseListShareCasePicker)
        }
    }
}

struct CaseListFeature: DWReducer {
    private let repository: CaseRepositoryProtocol
    init(repository: CaseRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        var selectedTab: CaseListPickerTab = .allCase
        var cases: [Case] = []
        
        // TODO: 지금 로직에서는 해당 부분 적용 x, 추후 공유 기능 추가되면 수정
        var shareCases: [Case] = []
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear
        case loadCases([Case])
        case setTab(CaseListPickerTab)
        case deleteTapped(item: Case)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            return .task { [repository] in
                do {
                    let items = try await repository.fetchCases()
                    return .loadCases(items)
                } catch {
                    return .none
                }
            }
            
        case let .loadCases(cases):
            state.cases = cases
            return .none
            
        case let .setTab(tab):
            state.selectedTab = tab
            return .none
        
        case let .deleteTapped(item):
            return .task { [repository] in
                do {
                    try await repository.deleteCase(id: item.id)
                    let items = try await repository.fetchCases()
                    return .loadCases(items)
                } catch {
                    return .none
                }
            }
        }
    }
}
