//
//  DashboardFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct DashboardFeature: DWReducer {
    
    // MARK: - State
    
    struct State: DWState {
        var tab: DashboardPickerTab = .visitDuration
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case setTab(DashboardPickerTab)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
            
        case .setTab(let tab):
            state.tab = tab
            return .none
        }
    }
}
