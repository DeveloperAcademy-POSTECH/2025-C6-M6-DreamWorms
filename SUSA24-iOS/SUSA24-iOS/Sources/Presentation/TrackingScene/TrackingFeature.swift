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
    
    struct State: DWState {}
    
    // MARK: - Action
    
    enum Action: DWAction {}
    
    // MARK: - Reducer
    
    func reduce(into _: inout State, action: Action) -> DWEffect<Action> {
        switch action {}
    }
}
