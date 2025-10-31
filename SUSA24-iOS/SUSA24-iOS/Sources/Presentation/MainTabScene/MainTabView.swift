//
//  MainTabView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct MainTabView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: MainTabFeature.State(),
        reducer: MainTabFeature()
    )
    
    // MARK: - Properties
        
    // MARK: - View
    
    var body: some View {
        TabView(
            selection: Binding(
                get: { store.state.selectedTab },
                set: { store.send(.selectTab($0)) }
            )
        ) {
            Tab(value: MainTabIdentifier.map) {
                MapView()
            } label: {
                MainTabIdentifier.map.tabLabel
            }
            
            Tab(value: MainTabIdentifier.dashboard) {
                DashboardView()
            } label: {
                MainTabIdentifier.dashboard.tabLabel
            }
            
            Tab(value: MainTabIdentifier.onePage) {
                OnePageView()
            } label: {
                MainTabIdentifier.onePage.tabLabel
            }
        }
    }
}

// MARK: - Extension Methods

extension MainTabView {}

// MARK: - Private Extension Methods

private extension MainTabView {}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(AppCoordinator())
}
