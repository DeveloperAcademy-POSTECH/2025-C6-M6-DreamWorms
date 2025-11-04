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
    
    @State private var selectedDetent: PresentationDetent = PresentationDetent.height(66)
    
    private let mapShortDetent = PresentationDetent.height(73)
    private let mapMidDetnet   = PresentationDetent.fraction(0.4)
    private let mapLargeDetent = PresentationDetent.large
    private let otherDetent    = PresentationDetent.height(66)
    
    private var showDividerByDetent: Bool {
        let detentsShowingDivider: Set<PresentationDetent> = [mapMidDetnet, mapLargeDetent]
        return detentsShowingDivider.contains(selectedDetent)
    }
        
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
            DWTabBar<TimeLineView>(
                activeTab: Binding(
                    get: { store.state.selectedTab },
                    set: { store.send(.selectTab($0)) }
                ),
                showDivider: showDividerByDetent
            ) {
                TimeLineView()
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
