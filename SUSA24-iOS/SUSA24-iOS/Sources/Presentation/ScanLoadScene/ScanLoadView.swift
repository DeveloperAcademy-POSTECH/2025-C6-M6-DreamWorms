//
//  ScanLoadView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

/// 문서 스캔 분석 화면
///
/// LoadingAnimationView를 표시하며 백그라운드에서 여러 이미지를 분석합니다.
/// 분석 완료 후 자동으로 ScanListView로 이동합니다.
/// 추출 실패 시 confirmationDialog로 재촬영 여부를 사용자에게 물어봅니다.
struct ScanLoadView: View {
    // MARK: - Dependencies
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    @State private var store: DWStore<ScanLoadFeature>
    
    private let caseID: UUID
    private let photos: [CapturedPhoto]
    
    // MARK: - State
    
    @State private var showRetryDialog: Bool = false
    
    // MARK: - Initialization
    
    init(
        caseID: UUID,
        photos: [CapturedPhoto],
        store: DWStore<ScanLoadFeature>
    ) {
        self.caseID = caseID
        self.photos = photos
        _store = State(initialValue: store)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()
                
                LoadingAnimationView()
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: store.state.isScanning)
                
                VStack(spacing: 8) {
                    Text(.scanLoadTitle)
                        .font(.titleSemiBold18)
                        .foregroundColor(.labelNeutral)
                    
                    Text(.scanLoadSubTitle)
                        .font(.bodyMedium14)
                        .foregroundStyle(.labelAssistive)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // 스캔 시작
            store.send(.startScanning(photos: photos))
        }
        .onChange(of: store.state.isCompleted) { _, isCompleted in
            guard isCompleted else { return }
            
            // 추출 결과가 있을 때: 목록 뷰로 이동
            if !store.state.scanResults.isEmpty {
                navigateToScanList()
            }
            // 추출 결과가 없거나 (빈 배열) 오류 메시지가 있을 때: 다이얼로그 표시
            else if store.state.errorMessage != nil || store.state.scanResults.isEmpty {
                showRetryDialog = true
            }
        }
        .dwAlert(
            isPresented: $showRetryDialog,
            title: "추출된 주소가 없습니다.",
            message: "다시 촬영하시겠습니까?",
            primaryButton: DWAlertButton(
                title: "다시 촬영",
                style: .default
            ) {
                handleRetry()
            },
            secondaryButton: DWAlertButton(
                title: "취소",
                style: .cancel
            ) {
                handleCancel()
            }
        )
    }
}

// MARK: - Subviews

private extension ScanLoadView {
    /// ScanListView replaceLast
    func navigateToScanList() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.5))
            
            // TODO: ScanListView 연결부분
            //            coordinator.replaceLast(
            //                .scanListScene(
            //                    caseID: caseID,
            //                    scanResults: store.state.scanResults
            //                )
            //            )
        }
    }
    
    func handleRetry() {
        coordinator.pop()
    }
    
    /// 취소 - MapView로
    func handleCancel() {
        // ScanLoadView + CameraView 제거 → MapView로
        if coordinator.path.count >= 2 {
            coordinator.popToDepth(2)
        } else {
            coordinator.popToRoot()
        }
    }
}

// MARK: - Preview

// #Preview {
//    let mockPhotos: [CapturedPhoto] = []
//
//    let store = DWStore(
//        initialState: ScanLoadFeature.State(),
//        reducer: ScanLoadFeature()
//    )
//
//    ScanLoadView(
//        caseID: UUID(),
//        photos: mockPhotos,
//        store: store
//    )
//    .environment(AppCoordinator())
// }
