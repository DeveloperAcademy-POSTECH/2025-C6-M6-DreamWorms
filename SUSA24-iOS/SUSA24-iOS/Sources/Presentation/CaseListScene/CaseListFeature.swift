//
//  CaseListFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import CoreData
import SwiftUI

struct CaseListFeature: DWReducer {
    
    private let repository: CaseRepositoryProtocol
    init(repository: CaseRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        var cases: [Case] = []
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear
        case loadCases([Case])
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
            
        case .loadCases(let cases):
            state.cases = cases
            return .none
            
        case .deleteTapped(let item):
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
