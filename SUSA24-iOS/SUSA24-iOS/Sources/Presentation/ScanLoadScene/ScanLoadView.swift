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
        .alert(
            String(localized: .scanLoadFailedTitle),
            isPresented: $showRetryAlert,
            actions: {
                Button(String(localized: .scanLoadTry), role: .confirm) {
                    handleRetry()
                }
                Button(String(localized: .cancelDefault), role: .cancel) {
                    handleCancel()
                }
            },
            message: {
                Text(String(localized: .scanLoadFailedContent))
            }
        )
    }
}

private extension ScanLoadView {
    func navigateToScanList() {
        coordinator.push(
            .scanListScene(
                caseID: caseID,
                scanResults: store.state.scanResults
            )
        )
    }

    func handleRetry() {
        camera.clearAllPhotos()
        coordinator.pop()
    }

    func handleCancel() {
        camera.clearAllPhotos()
        coordinator.popToDepth(2)
    }
}
