//
//  CameraView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//

import SwiftUI

struct CameraView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    @State private var store: DWStore<CameraFeature>
    @State private var showExitConfirmation: Bool = false
    
    private let camera: CameraModel
    
    init(store: DWStore<CameraFeature>, camera: CameraModel) {
        _store = State(initialValue: store)
        self.camera = camera
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - 카메라 프리뷰
                
                CameraPreview(source: store.state.previewSource)
                    .ignoresSafeArea()
                
                // MARK: - 문서 감지 오버레이
                
                //                if store.state.isDocumentDetectionEnabled,
                //                   let detection = store.state.documentDetection
                //                {
                //                    DocumentDetectionOverlayView(
                //                        documentDetection: detection,
                //                        screenSize: geometry.size
                //                    )
                //                    .ignoresSafeArea()
                //                    .id(detection.timestamp)
                //                    .onTapGesture {
                //                        store.send(.documentOverlayTapped)
                //                    }
                //                }
                
                // MARK: - 헤더
                
                VStack(spacing: 0) {
                    CameraHeader(
                        onBackTapped: handleBackTapped,
                        onScanTapped: {
                            // 한번 더 검사
                            guard store.state.allPhotos.count > 0 else { return }
                            
                            let photosToScan = store.state.allPhotos
                            
                            coordinator.push(
                                .scanLoadScene(
                                    caseID: store.state.caseID,
                                    photos: photosToScan
                                )
                            )
                            
                            store.send(.deleteAllPhotos)
                        },
                        showScanButton: store.state.photoCount > 0
                    )
                    
                    Spacer()
                        .allowsHitTesting(false)
                }
                
                // MARK: - 컨트롤러
                
                VStack(spacing: 0) {
                    Spacer()
                        .allowsHitTesting(false)
                    
                    CameraController(
                        count: store.state.photoCount,
                        uiImage: store.state.lastThumbnail,
                        isCapturing: store.state.isCapturing,
                        onDetailsTapped: {
                            coordinator.push(
                                .photoDetailsScene(
                                    photos: store.state.allPhotos,
                                    camera: camera
                                )
                            )
                        },
                        onPhotoCaptureTapped: {
                            store.send(.captureButtonTapped)
                        }
                    )
                }
            }
            .contentShape(Rectangle())
            .gesture(pinchGesture)
            .onTapGesture { location in
                handleTapGesture(location, in: geometry)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            store.send(.onAppear)
        }
        .toast(
            isPresented: Binding(
                get: { store.state.showToast },
                set: { if !$0 { store.send(.hideToast) } }
            ),
            message: store.state.toastMessage
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
        .alert(
            String(localized: .cameraBackSheetTitle),
            isPresented: $showExitConfirmation
        ) {
            Button(String(localized: .cameraBackSheetActionConfirm), role: .destructive) {
                Task {
                    camera.clearAllPhotos()
                }
                coordinator.pop()
            }
            Button(String(localized: .cancelDefault), role: .cancel) {}
        }
    }
}

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
            .onEnded { _ in
                store.send(.pinchZoomEnded)
            }
    }
    
    func handleTapGesture(_ location: CGPoint, in geometry: GeometryProxy) {
        if store.state.isDocumentDetectionEnabled,
           store.state.documentDetection != nil
        {
            return
        }
        
        // 일반 탭 → 포커스
        let normalizedPoint = CGPoint(
            x: location.x / geometry.size.width,
            y: location.y / geometry.size.height
        )
        store.send(.tapToFocus(normalizedPoint))
    }
}
