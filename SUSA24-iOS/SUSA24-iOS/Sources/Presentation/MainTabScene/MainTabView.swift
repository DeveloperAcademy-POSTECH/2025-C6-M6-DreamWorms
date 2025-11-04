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
    
    @State var store: DWStore<MainTabFeature>
    @State var mapStore: DWStore<MapFeature>
    
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
                MapView(store: mapStore)
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

//#Preview {
//    let mainTabStore = DWStore(
//        initialState: MainTabFeature.State(),
//        reducer: MainTabFeature()
//    )
//    let mapStore = DWStore(
//        initialState: MapFeature.State(caseId: UUID()),
//        reducer: MapFeature(repository: MockLocationRepository())
//    )
//    return MainTabView(mainTabStore: mainTabStore, mapStore: mapStore)
//        .environment(AppCoordinator())
//}
