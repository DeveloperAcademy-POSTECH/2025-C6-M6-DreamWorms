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
        ZStack {
            switch store.state.selectedTab {
            case .map: MapView()
            case .dashboard: DashboardView()
            case .onePage: OnePageView()
            }
        }
        .sheet(isPresented: .constant(true)) {
            DWTabBar(
                activeTab: Binding(
                    get: { store.state.selectedTab },
                    set: { store.send(.selectTab($0)) }
                )
            )
            .presentationDetents(
                store.state.selectedTab == .map
                ? [.height(71), .fraction(0.4), .large]
                : [.height(63)]
            )
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(store.state.selectedTab == .map ? .visible : .hidden)
            .interactiveDismissDisabled(true)
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
