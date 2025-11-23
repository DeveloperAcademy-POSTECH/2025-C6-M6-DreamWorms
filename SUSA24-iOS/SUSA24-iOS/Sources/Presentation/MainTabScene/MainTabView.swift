//
//  MainTabView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct MainTabView<MapView: View, TrackingView: View, DashboardView: View>: View {
    @Environment(TabBarVisibility.self)
    private var tabBarVisibility

    // MARK: - Dependencies
    
    @Bindable private var dispatcher: MapDispatcher
        
    @State var store: DWStore<MainTabFeature>
    @State var mapStore: DWStore<MapFeature>
    @State var timeLineStore: DWStore<TimeLineFeature>
        
    // MARK: - Properties
    
    @State private var selectedDetent: PresentationDetent

    private let mapShortDetent = PresentationDetent.height(73)
    private let mapMidDetent = PresentationDetent.fraction(0.4)
    private let mapLargeDetent = PresentationDetent.large
    private let otherDetent = PresentationDetent.height(66)
    
    private var showDividerByDetent: Bool {
        let detentsShowingDivider: Set<PresentationDetent> = [mapMidDetent, mapLargeDetent]
        return detentsShowingDivider.contains(selectedDetent)
    }
    
    private var shouldHideTimeline: Bool {
        if store.state.selectedTab == .map {
            selectedDetent == mapShortDetent
        } else {
            selectedDetent == otherDetent
        }
    }
    
    private let mapView: () -> MapView
    private let trackingView: () -> TrackingView
    private let dashboardView: () -> DashboardView
    private var timeLineView: some View {
        TimeLineView(store: timeLineStore)
    }
    
    // MARK: - Init
    
    init(
        store: DWStore<MainTabFeature>,
        timeLineStore: DWStore<TimeLineFeature>,
        mapStore: DWStore<MapFeature>,
        dispatcher: MapDispatcher,
        @ViewBuilder mapView: @escaping () -> MapView,
        @ViewBuilder trackingView: @escaping () -> TrackingView,
        @ViewBuilder dashboardView: @escaping () -> DashboardView
    ) {
        self._store = State(initialValue: store)
        self._timeLineStore = State(initialValue: timeLineStore)
        self._mapStore = State(initialValue: mapStore)
        self._dispatcher = Bindable(dispatcher)
        self.mapView = mapView
        self.trackingView = trackingView
        self.dashboardView = dashboardView
        self.selectedDetent = mapMidDetent
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            switch store.state.selectedTab {
            case .map: mapView()
            case .tracking: trackingView()
            case .analyze: dashboardView()
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
                showDivider: showDividerByDetent,
                hideContent: shouldHideTimeline
            ) {
                timeLineView
            }
            .presentationDetents(
                store.state.selectedTab == .map
                    ? [mapShortDetent, mapMidDetent, mapLargeDetent]
                    : [otherDetent],
                selection: $selectedDetent
            )
            .presentationBackgroundInteraction(.enabled)
            .presentationContentInteraction(.scrolls)
            .presentationDragIndicator(store.state.selectedTab == .map ? .visible : .hidden)
            .interactiveDismissDisabled(true)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            store.send(.onAppear)
        }
        .onChange(of: store.state.caseInfo) { _, newCaseInfo in
            guard let caseInfo = newCaseInfo else { return }
            // caseInfo 로드 시점에 locations도 함께 업데이트 (초기 바인딩 포함)
            timeLineStore.send(.updateData(
                caseInfo: caseInfo,
                locations: store.state.locations
            ))
        }
        .onChange(of: store.state.locations) { _, newLocations in
            guard let caseInfo = store.state.caseInfo else { return }
            // Timeline에 전달
            timeLineStore.send(.updateData(
                caseInfo: caseInfo,
                locations: newLocations
            ))
        }
        .onChange(of: selectedDetent) { _, newDetent in
            // 시트를 최소 높이로 내렸을 때는 셀 타임라인 모드를 해제합니다.
            let isShortDetent = (newDetent == mapShortDetent || newDetent == otherDetent)
            if isShortDetent {
                timeLineStore.send(.clearCellFilter)
            }
            
            // 타임라인 시트 상태를 MapFeature로 전달 (PlaceInfoSheet 표시 제어용)
            // isShortDetent = true → isActive = false (최소화 = 비활성화)
            // isShortDetent = false → isActive = true (올라와 있음 = 활성화)
            let isActive = !isShortDetent
            mapStore.send(.updateTimelineSheetState(isActive: isActive))
        }
        .onAppear {
            // 초기 상태를 즉시 전달
            let isShortDetent = (selectedDetent == mapShortDetent || selectedDetent == otherDetent)
            let isActive = !isShortDetent
            mapStore.send(.updateTimelineSheetState(isActive: isActive))
        }
        .onChange(of: store.state.selectedTab) { _, newTab in
            if newTab == .map {
                // Map 탭으로 복귀 시 중간 detent로 설정
                selectedDetent = mapMidDetent
            } else {
                selectedDetent = otherDetent
            }
        }
        .onChange(of: dispatcher.request) { _, request in
            guard let request else { return }
            switch request {
            case let .focusCellTimeline(cellKey, title):
                // NOTE: 탭or네비게이션 구조 뜯으면 수정될 코드. 현재 코드에 맞게 적용함.
                // PlaceInfoSheet가 열려있으면 먼저 닫기
                // shouldMinimizeTimeline: false (타임라인 올리려고 하므로 최소화하지 않음)
                // shouldDeselectMarker: false (셀 마커 선택을 유지)
                if mapStore.state.isPlaceInfoSheetPresented {
                    mapStore.send(.hidePlaceInfo(shouldMinimizeTimeline: false, shouldDeselectMarker: false))
                }
                // Idle 핀 제거 (셀 마커를 탭했으므로)
                if mapStore.state.idlePinCoordinate != nil {
                    mapStore.send(.clearIdlePin)
                }
                // 먼저 타임라인 상태를 셀 전용으로 바꾼 뒤 시트를 중간 detent로 올립니다.
                timeLineStore.send(.applyCellFilter(cellKey: cellKey, title: title))
                selectedDetent = mapMidDetent
                dispatcher.consume()
            default:
                break
            }
        }
        // 외부에서 시트의 높이를 Mid로 맞춰달라는 요청이 왔을 때 수행
        .onReceive(NotificationCenter.default.publisher(for: .resetDetentToMid)) { _ in
            if selectedDetent != mapMidDetent {
                selectedDetent = mapMidDetent
            }
        }
        // 외부에서 시트의 높이를 Short로 맞춰달라는 요청이 왔을 때 수행
        .onReceive(NotificationCenter.default.publisher(for: .resetDetentToShort)) { _ in
            if selectedDetent != mapShortDetent {
                selectedDetent = mapShortDetent
            }
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
