//
//  OnePageFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct OnePageFeature: DWReducer {
    private let categoryTypeMap: [Category: [Int]] = [
        .residence: [0], .workplace: [1], .others: [3], .all: [0, 1, 3]
    ]
    
    private let repository: LocationRepositoryProtocol
    init(repository: LocationRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        var selection: Category = .all
        var caseID: UUID? = nil
        var items: [Location] = []
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case selectionChanged(Category)
        case onAppear(UUID)
        case loadLocations(UUID, Category)
        case setLocationItems([Location])
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .selectionChanged(let category):
            state.selection = category
            guard let caseId = state.caseID else { return .none }
            return .task { [] in
                do {
                    return .loadLocations(caseId, category)
                } catch {
                    return .setLocationItems([])
                }
            }

        case .onAppear(let caseID):
            state.caseID = caseID
            let selection = state.selection
            return .task {
                return .loadLocations(caseID, selection)
            }

        case .loadLocations(let caseID, let selection):
            return .task { [repository, categoryTypeMap] in
                do {
                    let types = categoryTypeMap[selection] ?? [0, 1, 3]
                    let locations = try await repository.fetchNoCellLocations(
                        caseId: caseID,
                        locationType: types
                    )
                    return .setLocationItems(locations)
                } catch {
                    return .setLocationItems([])
                }
            }
            
        case .setLocationItems(let locations):
            state.items = locations
            return .none
        }
    }
}
