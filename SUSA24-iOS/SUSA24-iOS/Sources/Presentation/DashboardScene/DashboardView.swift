//
//  DashboardView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct DashboardView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: DashboardFeature.State(),
        reducer: DashboardFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack {
                Text(.testAnalyze)
                    .font(.titleSemiBold22)
                    .kerning(-0.44)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                
                Picker(
                    "",
                    selection: Binding(
                        get: { store.state.tab },
                        set: { store.send(.setTab($0)) }
                    )
                ) {
                    ForEach(DashboardPickerTab.allCases, id: \.title) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 295)
                .padding(.top, 38)
                
                DashboardSectionHeader(title: store.state.tab.sectionTitle)
                    .setupDescription(store.state.tab.sectionDescription)
                    .padding(.top, 24)
                
                DashboardSectionHeader(title: String(localized: .dashboardVisitDurationCellTowerTitle))
                    .padding(.top, 24)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Extension Methods

extension DashboardView {}

// MARK: - Private Extension Methods

private extension DashboardView {}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AppCoordinator())
}
