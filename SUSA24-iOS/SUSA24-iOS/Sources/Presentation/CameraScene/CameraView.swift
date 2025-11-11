//
//  CameraView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//

import SwiftUI

/// 카메라 촬영 화면 - 순수 UI만 담당
struct CameraView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    // MARK: - Dependencies
    
    @State private var store: DWStore<CameraFeature>
    
    // MARK: - State
    
    // 뒤로가기 confirm
    @State private var showExitConfirmation: Bool = false
    
    // MARK: - Initialization
    
    // PhotoDetails 에 넘겨야함
    private let camera: CameraModel
    
    init(store: DWStore<CameraFeature>, camera: CameraModel) {
        _store = State(initialValue: store)
        self.camera = camera
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // MARK: - 카메라 프리뷰 (전체 화면)
            CameraPreview(source: store.state.previewSource)
                .ignoresSafeArea()
            
            // MARK: - 문서 감지 오버레이 (조건부 표시)
            // TODO: UIScreen 제거
            if store.state.isDocumentDetectionEnabled,
                let detection = store.state.documentDetection {
                DocumentDetectionOverlayView(
                    documentDetection: detection,
                    screenSize: UIScreen.main.bounds.size
                )
                .ignoresSafeArea()
                .id(detection.timestamp)
            }
            
            // MARK: - 렌즈 얼룩 상태 표시 (조건부)
            if store.state.isLensSmudgeDetectionEnabled,
                let smudge = store.state.lensSmudgeDetection {
                LensSmudgeOverlay(smudge: smudge)
            }
            
            // MARK: - 헤더 (상단 오버레이)
            VStack(spacing: 0) {
                CameraHeader(
                    onBackTapped: handleBackTapped,
                    onScanTapped: { coordinator.push(.scanLoadScene) },
                    showScanButton: store.state.photoCount > 0
                )
                
                Spacer()
                    .allowsHitTesting(false)
            }
            
            // MARK: - 컨트롤러 (하단 오버레이)
            VStack(spacing: 0) {
                Spacer()
                    .allowsHitTesting(false)
                
                CameraController(
                    count: store.state.photoCount,
                    uiImage: store.state.lastThumbnail,
                    isCapturing: store.state.isCapturing,
                    onDetailsTapped: {
                        coordinator.push(.photoDetailsScene(photos: store.state.allPhotos, camera: camera))
                    },
                    onPhotoCaptureTapped: {
                        store.send(.captureButtonTapped)
                    }
                )
            }
            
            // MARK: - 설정 메뉴 (우측 하단)
            // 일단은 임시
//            VStack {
//                Spacer()
//                
//                HStack {
//                    Spacer()
//                    
//                    Menu {
//                        // MARK: - 기본 설정
//                        Section("기본 설정") {
//                            // Torch
//                            Button(action: { store.send(.toggleTorch) }) {
//                                Label(
//                                    "플래시",
//                                    systemImage: store.state.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill"
//                                )
//                            }
//                            
//                            // 자동 포커스
//                            Button(action: { store.send(.toggleAutoFocus) }) {
//                                Label(
//                                    "자동 포커스",
//                                    systemImage: store.state.isAutoFocusEnabled ? "checkmark" : ""
//                                )
//                            }
//                        }
//                        
//                        // MARK: - Vision 기능
//                        Section("Vision 기능") {
//                            // 문서 인식
//                            Button(action: { store.send(.toggleDocumentDetection) }) {
//                                Label {
//                                    VStack(alignment: .leading, spacing: 2) {
//                                        Text("문서 인식")
//                                        if store.state.isDocumentDetectionEnabled,
//                                            let detection = store.state.documentDetection {
//                                            Text("신뢰도: \(Int(detection.confidence * 100))%")
//                                                .font(.caption2)
//                                                .foregroundColor(.secondary)
//                                        }
//                                    }
//                                } icon: {
//                                    Image(systemName: store.state.isDocumentDetectionEnabled ? "doc.viewfinder.fill" : "doc.viewfinder")
//                                }
//                            }
//                            
//                            // 렌즈 얼룩 감지
//                            Button(action: { store.send(.toggleLensSmudgeDetection) }) {
//                                Label {
//                                    VStack(alignment: .leading, spacing: 2) {
//                                        Text("렌즈 얼룩 감지")
//                                        if store.state.isLensSmudgeDetectionEnabled,
//                                            let smudge = store.state.lensSmudgeDetection {
//                                            Text("\(smudge.statusColor) \(smudge.statusText)")
//                                                .font(.caption2)
//                                                .foregroundColor(.secondary)
//                                        }
//                                    }
//                                } icon: {
//                                    Image(systemName: store.state.isLensSmudgeDetectionEnabled ? "camera.filters" : "camera")
//                                }
//                            }
//                        }
//                    } label: {
//                        DWGlassEffectCircleButton(
//                            image: Image(systemName: "ellipsis"),
//                            action: {} // Menu가 처리하므로 빈 액션
//                        )
//                        .setupSize(48)
//                        .setupIconSize(20)
//                    }
//                    .padding(.trailing, 16)
//                    .padding(.bottom, 150)
//                }
//            }
        }
        .contentShape(Rectangle())
        .gesture(pinchGesture)
        .onTapGesture(perform: handleTapGesture)
        .navigationBarBackButtonHidden()
        .task {
            store.send(.onAppear)
        }
        .toast(
            isPresented: Binding(
                get: { store.state.showToast },
                set: { if !$0 { store.send(.hideToast) } }
            ),
            message: String(localized: .cameraPhotolimitMessage)
        )
        .onAppear {
            store.send(.viewDidAppear)
        }
        .onDisappear {
            store.send(.viewDidDisappear)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                store.send(.sceneDidBecomeActive)
            case .inactive, .background:
                store.send(.sceneDidEnterBackground)
            @unknown default:
                break
            }
        }
        .confirmationDialog("", isPresented: $showExitConfirmation) {
            Button(
                String(localized: .cameraExitConfirm),
                role: .destructive
            ) {
                coordinator.pop()
            }
            Button(String(localized: .cameraExitCancel)) {
            }
        } message: {
            Text(String(localized: .cameraExitAlertContent))
        }
    }
}

// MARK: - Private Computed Properties

private extension CameraView {
    
    func handleBackTapped() {
        if store.state.photoCount > 0 {
            showExitConfirmation = true
        } else {
            coordinator.pop()
        }
    }
    
    var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                store.send(.pinchZoomChanged(scale))
            }
            .onEnded { finalScale in
                store.send(.pinchZoomEnded)
            }
    }
    
    func handleTapGesture(_ location: CGPoint) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first else {
                return
        }
        
        let normalizedX = location.x / window.bounds.width
        let normalizedY = location.y / window.bounds.height
        let focusPoint = CGPoint(x: normalizedX, y: normalizedY)
        
        store.send(.tapToFocus(focusPoint))
    }
    
    func statusBackgroundColor(_ confidence: Float) -> Color {
        if confidence > 0.7 {
            return Color.red.opacity(0.6)
        } else if confidence > 0.4 {
            return Color.yellow.opacity(0.6)
        } else {
            return Color.green.opacity(0.6)
        }
    }
}
