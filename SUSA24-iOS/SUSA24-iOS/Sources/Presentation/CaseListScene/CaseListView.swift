//
//  CaseListView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct CaseListView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    @Environment(\.managedObjectContext)
    private var context
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: CaseListFeature.State(),
        reducer: CaseListFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        VStack {
            CaseListHeader(
                onSettingTapped: { coordinator.push(.settingScene) }
            )
            .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.state.cases) { item in
                        CaseCard(
                            item: item,
                            onEdit: {},
                            onShare: {},
                            onDelete: {}
                        )
                        .padding(.horizontal, 16)
                        .onTapGesture { coordinator.push(.mainTabScene) }
                    }
                }
                .padding(.bottom, 90)
            }
        }
        .overlay(alignment: .bottom) {
            CaseListBottomFade(
                onAddCaseTapped: { coordinator.push(.caseAddScene) }
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Extension Methods

extension CaseListView {}

// MARK: - Private Extension Methods

private extension CaseListView {}

// MARK: - Preview

#Preview {
    CaseListView()
        .environment(AppCoordinator())
}
