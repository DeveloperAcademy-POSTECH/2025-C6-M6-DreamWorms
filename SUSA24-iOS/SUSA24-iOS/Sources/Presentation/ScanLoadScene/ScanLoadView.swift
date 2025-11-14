//
//  ScanLoadView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

/// 문서 스캔 분석 화면
struct ScanLoadView: View {
    // MARK: - Dependencies
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    @State private var store: DWStore<ScanLoadFeature>
    
    private let caseID: UUID
    private let photos: [CapturedPhoto]
    
    // MARK: - State
    
    @State private var showRetryAlert: Bool = false
    
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
            
            if !store.state.scanResults.isEmpty {
                navigateToScanList()
            } else if store.state.errorMessage != nil || store.state.scanResults.isEmpty {
                showRetryAlert = true
            }
        }
        .dwAlert(
            isPresented: $showRetryAlert,
            title: String(localized: .scanLoadFailedTitle),
            message: String(localized: .scanLoadFailedContent),
            primaryButton: DWAlertButton(
                title: String(localized: .scanLoadTry),
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
            coordinator.replaceLast(
                .scanListScene(
                    caseID: caseID,
                    scanResults: store.state.scanResults
                )
            )
        }
    }
    
    func handleRetry() {
        coordinator.pop()
    }
    
    func handleCancel() {
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
