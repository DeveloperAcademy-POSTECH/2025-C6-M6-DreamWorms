//
//  MainTabView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct MainTabView<MapView: View,
                   DashboardView: View,
                   OnePageView: View,
                   TimeLineView: View
>: View {
    
    // MARK: - Dependencies
    
    @State var store: DWStore<MainTabFeature>
    
    // MARK: - Properties
    
    @State private var selectedDetent: PresentationDetent = PresentationDetent.height(66)
    
    private let mapShortDetent = PresentationDetent.height(73)
    private let mapMidDetnet   = PresentationDetent.fraction(0.4)
    private let mapLargeDetent = PresentationDetent.large
    private let otherDetent    = PresentationDetent.height(66)
    
    private var showDividerByDetent: Bool {
        let detentsShowingDivider: Set<PresentationDetent> = [mapMidDetnet, mapLargeDetent]
        return detentsShowingDivider.contains(selectedDetent)
    }
    
    private let mapView: () -> MapView
    private let dashboardView: () -> DashboardView
    private let onePageView: () -> OnePageView
    private let timeLineView: () -> TimeLineView
    
    // MARK: - Init
    
    init(
        store: DWStore<MainTabFeature>,
        @ViewBuilder mapView: @escaping () -> MapView,
        @ViewBuilder dashboardView: @escaping () -> DashboardView,
        @ViewBuilder onePageView: @escaping () -> OnePageView,
        @ViewBuilder timeLineView: @escaping () -> TimeLineView
    ) {
        self._store = State(initialValue: store)
        self.mapView = mapView
        self.dashboardView = dashboardView
        self.onePageView = onePageView
        self.timeLineView = timeLineView
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            switch store.state.selectedTab {
            case .map: mapView()
            case .dashboard: dashboardView()
            case .onePage: onePageView()
            }
        }
        .sheet(isPresented: .constant(true)) {
            DWTabBar(
                activeTab: Binding(
                    get: { store.state.selectedTab },
                    set: { store.send(.selectTab($0)) }
                ),
                showDivider: showDividerByDetent
            ) {
                // 이 부분에서 처음에 데이터 붙이면 store(caseInfo = nil, locations = [])임
//                timeLineView()
                ModuleFactory.shared.makeTimeLineView(
                    caseInfo: store.state.caseInfo,
                    locations: store.state.locations
                )
            }
            .presentationDetents(
                store.state.selectedTab == .map
                ? [mapShortDetent, mapMidDetnet, mapLargeDetent]
                : [otherDetent],
                selection: $selectedDetent
            )
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(store.state.selectedTab == .map ? .visible : .hidden)
            .interactiveDismissDisabled(true)
            .id(store.state.caseInfo?.id)
        }
        .navigationBarBackButtonHidden(true)
        .task { @MainActor in
            store.send(.onAppear)
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
