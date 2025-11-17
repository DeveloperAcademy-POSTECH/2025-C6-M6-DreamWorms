//
//  TrackingFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct TrackingFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - State
    
    struct State: DWState {
        var caseId: UUID?
        var locations: [Location] = []
        var isLoading: Bool = false
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear(UUID)
        case locationsLoaded([Location])
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .onAppear(caseId):
            state.caseId = caseId
            state.isLoading = true
            
            return .task { [repository] in
                do {
                    let locations = try await repository.fetchLocations(caseId: caseId)
                    let filtered = locations.filter { [0, 1, 3].contains($0.locationType) }
                    return .locationsLoaded(filtered)
                } catch {
                    return .locationsLoaded([])
                }
            }
            
        case let .locationsLoaded(locations):
            state.locations = locations
            state.isLoading = false
            return .none
        }
    }
}
