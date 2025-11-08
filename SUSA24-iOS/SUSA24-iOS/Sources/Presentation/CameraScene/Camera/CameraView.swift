//
//  CameraView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//

import SwiftUI

/// 카메라 촬영 화면 - 순수 UI만 담당
struct CameraView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store: DWStore<CameraFeature>
    
    // MARK: - Initialization
    
    init(store: DWStore<CameraFeature>) {
        _store = State(initialValue: store)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // MARK: - 카메라 프리뷰 (전체 화면)
            CameraPreview(source: store.state.previewSource)
                .ignoresSafeArea()
            
            // MARK: - 헤더 (상단 오버레이)
            VStack(spacing: 0) {
                CameraHeader(
                    onBackTapped: {
                        coordinator.pop()
                    },
                    // TODO: 연결해야함
                    onScanTapped: {
                    }
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
                    onDetailsTapped: {
                        store.send(.photoDetailsTapped)
                    },
                    onPhotoCaptureTapped: {
                        store.send(.captureButtonTapped)
                    }
                )
            }
        }
        .contentShape(Rectangle())
        .gesture(pinchGesture)
        .onTapGesture(perform: handleTapGesture)
        .navigationBarBackButtonHidden()
        .task {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
}

// MARK: - Private Computed Properties

private extension CameraView {
    
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
        // 화면 좌표 변환 - 정규화된 좌표 (0~1)
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
}

// MARK: - Preview

#Preview {
    let camera = CameraModel()
    let store = DWStore(
        initialState: CameraFeature.State(
            previewSource: camera.previewSource
        ),
        reducer: CameraFeature(camera: camera)
    )
    
    CameraView(store: store)
}
