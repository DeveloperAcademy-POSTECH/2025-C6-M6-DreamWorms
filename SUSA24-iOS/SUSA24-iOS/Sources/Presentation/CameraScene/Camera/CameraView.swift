//
//  CameraView.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/29/25.
//

import SwiftUI

struct CameraView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store: DWStore<CameraFeature>
    
    /// cameraManager는 의존성 주입 (소유하지 않음)
    private let cameraManager: CameraModel
    
    // MARK: - Gesture State
    
    @State private var lastZoomScale: CGFloat = 1.0
    
    // MARK: - Initialization
    
    init(store: DWStore<CameraFeature>, cameraManager: CameraModel) {
        _store = State(initialValue: store)
        self.cameraManager = cameraManager
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            // MARK: - 카메라 프리뷰 (전체 화면)
            CameraPreview(source: store.state.previewSource)
                .ignoresSafeArea()
                // MARK: - Pinch Zoom Gesture
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            handlePinchZoom(value)
                        }
                        .onEnded { _ in
                            lastZoomScale = 1.0
                        }
                )
                // MARK: - Tap to Focus Gesture
                .onTapGesture { location in
                    handleTapToFocus(at: location)
                }
            
            // MARK: - 헤더 (상단 오버레이)
            VStack(spacing: 0) {
                CameraHeader(onBackTapped: handleBackTapped, onScanTapped: {})
                    .allowsHitTesting(true)
                
                Spacer()
            }
            
            // MARK: - 컨트롤러 (하단 오버레이)
            VStack(spacing: 0) {
                Spacer()
                
                CameraController(
                    count: store.state.photoCount,
                    uiImage: store.state.lastThumbnail,
                    onDetailsTapped: handleDetailsTapped,
                    onPhotoCaptureTapped: handlePhotoCapture
                )
                .allowsHitTesting(true)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
}

// MARK: - Extension Methods
// TODO: 없애
extension CameraView {
    /// 뒤로가기 버튼 탭 핸들러
    private func handleBackTapped() {
        coordinator.pop()
    }
    
    /// 상세 보기 버튼 탭 핸들러
    private func handleDetailsTapped() {
        store.send(.showPhotoDetails)
    }
    
    /// 사진 캡처 버튼 탭 핸들러
    private func handlePhotoCapture() {
        store.send(.capturePhotoTapped)
    }
}

// MARK: - Private Extension Methods (Gestures)

private extension CameraView {
    /// Pinch Zoom 제스처 처리
    /// - Parameter scale: 핀치 제스처의 현재 스케일
    func handlePinchZoom(_ scale: CGFloat) {
        let delta = scale / lastZoomScale
        lastZoomScale = scale
        
        Task {
            await cameraManager.applyPinchZoom(delta: delta)
        }
    }
    
    /// Tap to Focus 제스처 처리
    /// - Parameter location: 화면에서의 탭 위치 (CGPoint)
    func handleTapToFocus(at location: CGPoint) {
        // 화면 좌표를 정규화된 좌표로 변환 (0~1)
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first else { return }
        
        let normalizedX = location.x / window.bounds.width
        let normalizedY = location.y / window.bounds.height
        let focusPoint = CGPoint(x: normalizedX, y: normalizedY)
        
        Task {
            await cameraManager.focusOnPoint(focusPoint)
        }
    }
}

// MARK: - Preview

//#Preview {
//    let cameraManager = CameraModel()
//    let store = DWStore(
//        initialState: CameraFeature.State(
//            previewSource: cameraManager.previewSource
//        ),
//        reducer: CameraFeature(cameraManager: cameraManager)
//    )
//
//    CameraView(store: store, cameraManager: cameraManager)
//        .environment(AppCoordinator())
//}
