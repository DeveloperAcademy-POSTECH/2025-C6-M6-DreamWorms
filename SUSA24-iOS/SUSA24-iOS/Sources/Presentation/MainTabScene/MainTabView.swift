//
//  MainTabView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct MainTabView<MapView: View, DashboardView: View, OnePageView: View>: View {
    @Environment(TabBarVisibility.self)
    private var tabBarVisibility

    // MARK: - Dependencies
    
    @State var store: DWStore<MainTabFeature>
    
    // MARK: - TimeLine Store (탭 전환 시에도 유지!)
    
    @State var timeLineStore: DWStore<TimeLineFeature>
    
    // MARK: - Properties
    
    @State private var selectedDetent: PresentationDetent = PresentationDetent.height(66)
    
    private let mapShortDetent = PresentationDetent.height(73)
    private let mapMidDetnet = PresentationDetent.fraction(0.4)
    private let mapLargeDetent = PresentationDetent.large
    private let otherDetent = PresentationDetent.height(66)
    
    private var showDividerByDetent: Bool {
        let detentsShowingDivider: Set<PresentationDetent> = [mapMidDetnet, mapLargeDetent]
        return detentsShowingDivider.contains(selectedDetent)
    }
    
    private let mapView: () -> MapView
    private let dashboardView: () -> DashboardView
    private let onePageView: () -> OnePageView
    private var timeLineView: some View {
        TimeLineView(store: timeLineStore)
    }
    
    // MARK: - Init
    
    init(
        store: DWStore<MainTabFeature>,
        timeLineStore: DWStore<TimeLineFeature>,
        @ViewBuilder mapView: @escaping () -> MapView,
        @ViewBuilder dashboardView: @escaping () -> DashboardView,
        @ViewBuilder onePageView: @escaping () -> OnePageView
    ) {
        self._store = State(initialValue: store)
        self._timeLineStore = State(initialValue: timeLineStore)
        self.mapView = mapView
        self.dashboardView = dashboardView
        self.onePageView = onePageView
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
        .sheet(isPresented: Binding(
            get: { tabBarVisibility.isVisible },
            set: { _ in }
        )) {
            DWTabBar(
                activeTab: Binding(
                    get: { store.state.selectedTab },
                    set: { store.send(.selectTab($0)) }
                ),
                showDivider: showDividerByDetent
            ) {
                timeLineView
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
        }
        .navigationBarBackButtonHidden(true)
        .task { store.send(.onAppear) }
        .onChange(of: store.state.caseInfo) { _, newCaseInfo in
            guard let caseInfo = newCaseInfo else { return }
            timeLineStore.send(.updateData(
                caseInfo: caseInfo,
                locations: store.state.locations
            ))
        }
        
        .onChange(of: selectedDetent) { _, newDetent in
            let isMinimized = (newDetent == mapShortDetent || newDetent == otherDetent)
            timeLineStore.send(.setMinimized(isMinimized))
        }
    }
}

// MARK: - Extension Methods

extension MainTabView {}

// MARK: - Private Extension Methods

private extension MainTabView {}

// MARK: - Preview

// #Preview {
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
// }
