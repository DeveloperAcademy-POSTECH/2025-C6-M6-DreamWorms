//
//  ScanListView.swift (UPDATED)
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import CoreData
import SwiftUI

/// 스캔 결과 목록 화면
///
/// - caseID 통일 (caseId → caseID)
/// - PinCategoryType 아이콘 및 텍스트 표시
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
                    isEnabled: .constant(store.state.canAddPin && !store.state.isSaving),
                    title: store.state.isSaving ? "저장 중..." : "핀 추가하기"
                ) {
                    store.send(.saveButtonTapped(caseID: caseID))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("저장 실패", isPresented: .constant(store.state.errorMessage != nil)) {
            Button("확인", role: .cancel) {
                store.send(.saveFailed(NSError(domain: "", code: 0)))
            }
        } message: {
            if let errorMessage = store.state.errorMessage {
                Text(errorMessage)
            }
        }
        .alert("저장 완료", isPresented: .constant(store.state.isSaveCompleted)) {
            Button("확인") { coordinator.popToRoot() }
        } message: {
            Text("선택한 주소가 지도에 추가되었습니다.")
        }
    }
}

// MARK: - Subviews

private extension ScanListView {
    var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("분석 결과가 없습니다")
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
                        address: result.address,
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let repository = LocationRepository(context: context)
    let feature = ScanListFeature(repository: repository)

    let mockResults = [
        ScanResult(
            address: "서울특별시 강남구 테헤란로 123",
            duplicateCount: 3,
            sourcePhotoIds: [UUID(), UUID(), UUID()]
        ),
        ScanResult(
            address: "서울특별시 서초구 반포대로 45",
            duplicateCount: 1,
            sourcePhotoIds: [UUID()]
        ),
    ]

    let store = DWStore(
        initialState: ScanListFeature.State(scanResults: mockResults),
        reducer: feature
    )

    return ScanListView(caseID: UUID(), store: store)
        .environment(AppCoordinator())
}
