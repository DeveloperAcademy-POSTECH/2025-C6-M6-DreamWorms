//
//  MainTabFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct MainTabFeature: DWReducer {
    
    // MARK: - State
    
    struct State: DWState {
        var selectedTab: MainTabIdentifier = .map
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case selectTab(MainTabIdentifier)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .selectTab(let tab):
            state.selectedTab = tab
            return .none
        }
    }
}
