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
    
    // MARK: - Dependencies
    
    @State var store: DWStore<CaseListFeature>

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
                            onDelete: { store.send(.deleteTapped(item: item)) }
                        )
                        .padding(.horizontal, 16)
                        .onTapGesture { coordinator.push(.mainTabScene(caseId: item.id)) }
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
        .onAppear {
            store.send(.onAppear)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Extension Methods

extension CaseListView {}

// MARK: - Private Extension Methods

private extension CaseListView {}

// MARK: - Preview

//#Preview {
//    CaseListView()
//        .environment(AppCoordinator())
//}
