//
//  MainTabView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct MainTabView<MapView: View,
                    DashboardView: View,
                    OnePageView: View>: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var store: DWStore<MainTabFeature>
    
    // MARK: - Properties
    
    private let mapView: () -> MapView
    private let dashboardView: () -> DashboardView
    private let onePageView: () -> OnePageView
    
    // MARK: - Init
    
    init(
        store: DWStore<MainTabFeature>,
        @ViewBuilder mapView: @escaping () -> MapView,
        @ViewBuilder dashboardView: @escaping () -> DashboardView,
        @ViewBuilder onePageView: @escaping () -> OnePageView
    ) {
        self._store = State(initialValue: store)
        self.mapView = mapView
        self.dashboardView = dashboardView
        self.onePageView = onePageView
    }
        
    // MARK: - View
    
    var body: some View {
        TabView(
            selection: Binding(
                get: { store.state.selectedTab },
                set: { store.send(.selectTab($0)) }
            )
        ) {
            Tab(value: MainTabIdentifier.map) {
                mapView()
            } label: {
                MainTabIdentifier.map.tabLabel
            }
            
            Tab(value: MainTabIdentifier.dashboard) {
                dashboardView()
            } label: {
                MainTabIdentifier.dashboard.tabLabel
            }
            
            Tab(value: MainTabIdentifier.onePage) {
                onePageView()
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
