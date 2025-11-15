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
        VStack(spacing: 0) {
            Text(.caseListNavigationTitle)
                .font(.titleSemiBold22)
                .kerning(-0.44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 64)
                .padding([.leading, .bottom], 24)
                .padding(.trailing, 16)
            
            // TODO: - 지원되지 않는 기능임에 따라 뷰에서 보이지 않게 처리
//            CaseListHeader(
//                onSettingTapped: { coordinator.push(.settingScene) }
//            )
//            .padding(.bottom, 24)
            
//            Picker("", selection: Binding(
//                get: { store.state.selectedTab },
//                set: { store.send(.setTab($0)) }
//            )) {
//                ForEach(CaseListPickerTab.allCases, id: \.title) { tab in
//                    Text(tab.title).tag(tab)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding(.horizontal, 16)
//            .padding(.bottom, 20)
            
            if store.state.selectedTab == .allCase, !store.state.cases.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.state.cases) { item in
                            CaseCard(
                                item: item,
                                onEdit: {},
                                onDelete: { store.send(.deleteTapped(item: item)) }
                            )
                            .padding(.horizontal, 16)
                            .onTapGesture { coordinator.push(.mainTabScene(caseID: item.id)) }
                        }
                    }
                    .padding(.bottom, 90)
                }
            } else {
                CaseListEmpty().padding(.bottom, 90)
            }
        }
        .overlay(alignment: .bottom) {
            CaseListBottomFade(
                onAddCaseTapped: { coordinator.push(.caseAddScene) }
            )
        }
        .task { store.send(.onAppear) }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Extension Methods

extension CaseListView {}

// MARK: - Private Extension Methods

private extension CaseListView {}

// MARK: - Preview

// #Preview {
//     CaseListView(
//        store: DWStore(
//            initialState: CaseListFeature.State(),
//            reducer: CaseListFeature(repository: MockCaseRepository())
//        )
//     )
//    .environment(AppCoordinator())
// }
