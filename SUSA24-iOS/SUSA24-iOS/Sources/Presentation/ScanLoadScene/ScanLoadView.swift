//
//  ScanLoadView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

/// 문서 스캔 분석 화면
struct ScanLoadView: View {
    @Environment(AppCoordinator.self)
    private var coordinator

    @State private var store: DWStore<ScanLoadFeature>

    private let caseID: UUID
    private let photos: [CapturedPhoto]
    private let camera: CameraModel

    @State private var showRetryAlert: Bool = false

    init(
        caseID: UUID,
        photos: [CapturedPhoto],
        camera: CameraModel,
        store: DWStore<ScanLoadFeature>
    ) {
        self.caseID = caseID
        self.photos = photos
        self.camera = camera
        _store = State(initialValue: store)
    }

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

private extension ScanLoadView {
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
        camera.clearAllPhotos()
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            coordinator.pop()
        }
    }

    func handleCancel() {
        camera.clearAllPhotos()
        
        if coordinator.path.count >= 2 {
            coordinator.popToDepth(2)
        } else {
            coordinator.popToRoot()
        }
    }
}
