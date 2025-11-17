//
//  ScanListView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//  Updated: 11/17/25 - Pass roadAddress and jibunAddress to ScanResultCard
//

import CoreData
import SwiftUI

/// 스캔 결과 목록 화면
///
/// - PinCategoryType 아이콘 및 텍스트 표시
/// - 중복 주소 감지 시 덮어쓰기 Alert 표시
struct ScanListView: View {
    // MARK: - Dependencies

    @Environment(AppCoordinator.self)
    private var coordinator

    @State private var store: DWStore<ScanListFeature>

    private let caseID: UUID

    // MARK: - Initialization

    init(caseID: UUID, store: DWStore<ScanListFeature>) {
        self.caseID = caseID
        _store = State(initialValue: store)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScanListHeader(
                onBackTapped: {
                    coordinator.pop()
                }
            )
            .padding(.bottom, 40)

            // MARK: - 리스트

            if store.state.scanResults.isEmpty {
                emptyView
            } else {
                contentView
            }

            Spacer()

            // MARK: - 하단 버튼

            VStack {
                DWButton(
                    isEnabled: isButtonEnabled,
                    title: String(localized: .scanListAddPin)
                ) {
                    store.send(.saveButtonTapped(caseID: caseID))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .dwAlert(
            isPresented: errorAlertPresented,
            title: String(localized: .saveFailButton),
            message: store.state.errorMessage ?? "",
            primaryButton: DWAlertButton(
                title: "확인",
                style: .cancel
            ) {
                store.send(.dismissErrorAlert)
            }
        )
        .dwAlert(
            isPresented: saveCompletedAlertPresented,
            title: String(localized: .saveSuccessButton),
            message: String(localized: .saveCompletedMessage),
            primaryButton: DWAlertButton(
                title: "확인",
                style: .default
            ) {
                store.send(.dismissSaveCompletedAlert)
                // MapView로 이동: CameraView와 ScanListView를 pop
                coordinator.popToDepth(2)
            }
        )
        .dwAlert(
            isPresented: duplicateAlertPresented,
            title: String(localized: .scanListPinAddDuplicateAlertTitle),
            message: String(format: NSLocalizedString("scanList_pin_add_duplicate_alert_content", comment: ""), store.state.duplicateAddress ?? ""),
            primaryButton: DWAlertButton(
                title: String(localized: .scanListPinAddDuplicateAlertButtonConfirm),
                style: .destructive
            ) {
                store.send(.confirmOverwrite)
            },
            secondaryButton: DWAlertButton(
                title: String(localized: .scanListPinAddDuplicateAlertButtonCancel),
                style: .cancel
            ) {
                store.send(.cancelOverwrite)
            }
        )
    }

    // MARK: - Computed Properties

    private var isButtonEnabled: Binding<Bool> {
        Binding(
            get: { store.state.canAddPin && !store.state.isSaving },
            set: { _ in }
        )
    }

    private var errorAlertPresented: Binding<Bool> {
        Binding(
            get: { store.state.errorMessage != nil },
            set: { if !$0 { store.send(.dismissErrorAlert) } }
        )
    }

    private var saveCompletedAlertPresented: Binding<Bool> {
        Binding(
            get: { store.state.isSaveCompleted },
            set: { if !$0 { store.send(.dismissSaveCompletedAlert) } }
        )
    }

    private var duplicateAlertPresented: Binding<Bool> {
        Binding(
            get: { store.state.showDuplicateAlert },
            set: { if !$0 { store.send(.cancelOverwrite) } }
        )
    }
}

// MARK: - Subviews

private extension ScanListView {
    var emptyView: some View {
        VStack {
            Text(String(localized: .scanResultFailedContent))
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var contentView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(store.state.scanResults.enumerated()), id: \.offset) { index, result in
                    ScanResultCard(
                        roadAddress: result.roadAddress, // ✅ 신주소 전달
                        jibunAddress: result.jibunAddress, // ✅ 구주소 전달
                        duplicateCount: result.duplicateCount,
                        isSelected: store.state.selectedIndex.contains(index),
                        selectedCategory: store.state.typeSelections[index],
                        onToggleSelection: {
                            store.send(.toggleSelection(index: index))
                        },
                        onCategorySelect: { type in
                            store.send(.selectType(index: index, type: type))
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
}

// MARK: - Preview

// #Preview {
//    let context = PersistenceController.preview.container.viewContext
//    let repository = LocationRepository(context: context)
//    let feature = ScanListFeature(repository: repository)
//
//    let mockResults = [
//        ScanResult(
//            roadAddress: "서울특별시 강남구 테헤란로 123",
//            jibunAddress: "서울 강남구 역삼동 789-12",
//            duplicateCount: 3,
//            sourcePhotoIds: [UUID(), UUID(), UUID()],
//            latitude: 37.5665,
//            longitude: 126.9780
//        ),
//        ScanResult(
//            roadAddress: "서울특별시 서초구 반포대로 45",
//            jibunAddress: "",
//            duplicateCount: 1,
//            sourcePhotoIds: [UUID()],
//            latitude: 37.5043,
//            longitude: 127.0044
//        ),
//    ]
//
//    let store = DWStore(
//        initialState: ScanListFeature.State(scanResults: mockResults),
//        reducer: feature
//    )
//
//    return ScanListView(caseID: UUID(), store: store)
//        .environment(AppCoordinator())
// }
