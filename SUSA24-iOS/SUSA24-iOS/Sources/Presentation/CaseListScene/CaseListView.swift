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
                                onEdit: { coordinator.push(.caseAddScene(caseID: item.id)) },
                                onDelete: { store.send(.deleteTapped(item: item)) },
                                onAddCellLog: {
                                    store.send(.cellLogMenuTapped(caseID: item.id))
                                },
                                onAddPinData: {
                                    store.send(.pinDataMenuTapped(caseID: item.id))
                                }
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
                onAddCaseTapped: { coordinator.push(.caseAddScene()) }
            )
        }
        .task { store.send(.onAppear) }
        .ignoresSafeArea(edges: .bottom)
        // 1116 목데이터 추가 - 덮어쓰기 Alert
        .dwAlert(
            isPresented: Binding(
                get: { store.state.isShowingOverwriteAlert },
                set: { _ in store.send(.dismissOverwriteAlert) }
            ),
            title: "기지국 데이터 덮어쓰기",
            message: "기존 기지국 데이터가 있습니다. 덮어쓰시겠습니까?",
            primaryButton: DWAlertButton(title: "덮어쓰기", style: .destructive) {
                if let caseID = store.state.targetCaseIdForCellLog {
                    store.send(.addCellLog(caseID: caseID, overwrite: true))
                }
            },
            secondaryButton: DWAlertButton(title: "취소", style: .cancel)
        )
        
        // 1116 목데이터 추가 - 성공 Alert
        .dwAlert(
            isPresented: Binding(
                get: { store.state.isShowingSuccessAlert },
                set: { _ in store.send(.dismissSuccessAlert) }
            ),
            title: "데이터 추가 완료",
            message: "기지국 위치 데이터가 성공적으로 추가되었습니다."
        )
        .dwAlert(
            isPresented: Binding(
                get: { store.state.isShowingPinDataOverwriteAlert },
                set: { _ in store.send(.dismissPinDataOverwriteAlert) }
            ),
            title: "핀 데이터 덮어쓰기",
            message: "기존 핀 데이터가 있습니다. 덮어쓰시겠습니까?",
            primaryButton: DWAlertButton(title: "덮어쓰기", style: .destructive) {
                if let caseID = store.state.targetCaseIdForPinData {
                    store.send(.addPinData(caseID: caseID, overwrite: true))
                }
            },
            secondaryButton: DWAlertButton(title: "취소", style: .cancel)
        )
        .dwAlert(
            isPresented: Binding(
                get: { store.state.isShowingPinDataSuccessAlert },
                set: { _ in store.send(.dismissPinDataSuccessAlert) }
            ),
            title: "데이터 추가 완료",
            message: "핀 위치 데이터가 성공적으로 추가되었습니다."
        )
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
