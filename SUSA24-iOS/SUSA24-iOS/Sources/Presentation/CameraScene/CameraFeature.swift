//
//  CameraFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//

import SwiftUI
import UIKit

/// - 카메라 생명주기 관리 (start/stop)
/// - 사진 촬영 및 관리 (최대 10장 제한)
/// - 줌 및 포커스 제어
/// - 고급 기능: Torch, 자동 포커스, 문서 인식, 렌즈 얼룩 감지
struct CameraFeature: DWReducer {
    // MARK: - Dependency Injection
    
    private let camera: CameraModel
    
    init(camera: CameraModel) {
        self.camera = camera
    }
    
    // MARK: - State
    
    struct State: DWState {
        // MARK: Case Info
        
        /// 현재 작업 중인 케이스 ID
        let caseID: UUID
        
        // MARK: Camera State
        
        /// 카메라 프리뷰 소스
        var previewSource: PreviewSource
        
        /// 카메라 상태
        var cameraStatus: CameraStatus = .notInitialized
        
        /// 카메라가 실행 중인지 여부
        var isRunning: Bool = false
        
        // MARK: Photo State
        
        /// 촬영된 사진의 개수
        var photoCount: Int = 0
        
        /// 마지막으로 촬영된 사진의 썸네일
        var lastThumbnail: UIImage?
        
        /// 모든 촬영된 사진
        var allPhotos: [CapturedPhoto] = []
        
        /// 사진 촬영이 가능한 상태인지 여부
        var isCaptureAvailable: Bool = true
        
        /// 현재 사진을 촬영 중인지 여부 (연속 탭 방지)
        var isCapturing: Bool = false
        
        // MARK: UI State
        
        /// 사진 상세보기 화면 표시 여부
        var isPhotoDetailsPresented: Bool = false
        
        /// 카메라 설정 Sheet 표시 여부
        var isCameraSettingsPresented: Bool = false
        
        // MARK: Gesture State
        
        /// Pinch Zoom의 마지막 스케일 값
        var lastZoomScale: CGFloat = 1.0
        
        /// 현재 줌 배율
        var currentZoomFactor: CGFloat = 1.0
        
        // MARK: Toast State
        
        /// 토스트 메시지 표시 여부
        var showToast: Bool = false
        
        /// 토스트 메시지 내용
        var toastMessage: String = ""
        
        // MARK: - Advanced Camera Features
        
        /// Torch (플래시) 활성화 여부
        var isTorchOn: Bool = false
        
        /// 자동 포커스 모드 활성화 여부
        var isAutoFocusEnabled: Bool = true
        
        /// 문서 인식 활성화 여부
        var isDocumentDetectionEnabled: Bool = false
        
        /// 렌즈 얼룩 감지 활성화 여부
        var isLensSmudgeDetectionEnabled: Bool = false
        
        /// Vision 프로세서 초기화 완료 여부
        var isVisionProcessorInitialized: Bool = false
        
        /// 문서 감지 결과 (overlay 표시용)
        var documentDetection: DocumentDetectionResult?
        
        /// 렌즈 얼룩 감지 결과
        var lensSmudgeDetection: LensSmudgeDetectionResult?
        
        // MARK: - Initialization
        
        init(caseID: UUID, previewSource: PreviewSource) {
            self.caseID = caseID
            self.previewSource = previewSource
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        // MARK: Lifecycle Actions
        
        case onAppear
        case viewDidAppear
        case viewDidDisappear
        case sceneDidBecomeActive
        case sceneDidEnterBackground
        
        // MARK: Navigation Actions
        
        // PhotoDetails/Scan으로 갈 때
        case pauseForNavigation
        // 뒤로가기로 나갈 때
        case stopForExit
        
        // MARK: Camera Control Actions
        
        case setCameraStatus(CameraStatus)
        case setCameraRunning(Bool)
        
        // MARK: Photo Capture Actions
        
        case captureButtonTapped
        case syncPhotoState
        case updatePhotoCount(Int)
        case updateThumbnail(UIImage?)
        case updateAllPhotos([CapturedPhoto])
        case updateCaptureAvailability(Bool)
        
        // MARK: UI Actions
        
        case photoDetailsTapped
        case closePhotoDetails
        case toggleCameraSettings
        
        // MARK: Gesture Actions
        
        case pinchZoomChanged(CGFloat)
        case pinchZoomEnded
        case tapToFocus(CGPoint)
        case updateZoomFactor(CGFloat)
        
        // MARK: Toast Actions
        
        case showToast
        case hideToast
        
        // MARK: - Advanced Camera Features Actions
        
        case toggleTorch
        case toggleAutoFocus
        case toggleDocumentDetection
        case toggleLensSmudgeDetection
        case visionProcessorInitialized
        case startDocumentDetectionStream
        case startLensSmudgeStream
        case updateDocumentDetection(DocumentDetectionResult?)
        case updateLensSmudgeDetection(LensSmudgeDetectionResult?)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
            // MARK: Lifecycle
            
        case .onAppear:
            return .task { [camera] in
                await camera.start()
                let status = await camera.cameraStatus
                
                await MainActor.run {
                    camera.enableVisionAnalysis()
                }
                
                Task {
                    await camera.startVisionAnalysis()
                }
                
                return .setCameraStatus(status)
            }
            
        // TODO: 처리
        case .viewDidAppear:
            print("viewDidAppear")
            camera.resumeCamera()
            return .send(.syncPhotoState)
            
        case .viewDidDisappear:
            print("viewDidDisappear")
            camera.stopVisionAnalysis()
            camera.pauseCamera()
            return .none
            
        case .sceneDidBecomeActive:
            print("sceneDidBecomeActive")
            camera.resumeCamera()
            return .none
            
        case .sceneDidEnterBackground:
            print("sceneDidEnterBackground")
            camera.pauseCamera()
            camera.stopVisionAnalysis()
            return .none
            
            // MARK: Navigation Contro
            
        case .pauseForNavigation:
            // PhotoDetails/Scan으로 갈 때 - 일시정지
            camera.pauseCamera()
            camera.stopVisionAnalysis()
            return .none
            
        case .stopForExit:
            // 뒤로가기로 나갈 때 - 세션 중지
            camera.stopVisionAnalysis()
            return .task { [camera] in
                await camera.stop()
                return .setCameraStatus(.stopped)
            }
            
            // MARK: Camera Control
            
        case let .setCameraStatus(status):
            state.cameraStatus = status
            
            if status == .running {
                return .task { [camera] in
                    let isRunning = await camera.isRunning
                    return .setCameraRunning(isRunning)
                }
            }
            return .none
            
        case let .setCameraRunning(isRunning):
            state.isRunning = isRunning
            return .none
            
            // MARK: Photo Capture
            
        case .captureButtonTapped:
            if state.photoCount >= 10 {
                return .send(.showToast)
            }
            
            guard state.isCaptureAvailable, !state.isCapturing else {
                return .none
            }
            
            state.isCapturing = true
            
            return .task { [camera] in
                do {
                    _ = try await camera.capturePhoto()
                    return .syncPhotoState
                } catch {
                    return .syncPhotoState
                }
            }
            
        case .syncPhotoState:
            return .task { [camera] in
                let photoCount = await camera.photoCount
                return .updatePhotoCount(photoCount)
            }
            
        case let .updatePhotoCount(count):
            state.photoCount = count
            
            if count >= 10 {
                state.isCaptureAvailable = false
            }
            
            return .task { [camera] in
                let thumbnail = await camera.lastThumbnail
                return .updateThumbnail(thumbnail)
            }
            
        case let .updateThumbnail(image):
            state.lastThumbnail = image
            
            return .task { [camera] in
                let allPhotos = await camera.getAllPhotos()
                return .updateAllPhotos(allPhotos)
            }
            
        case let .updateAllPhotos(photos):
            state.allPhotos = photos
            state.isCapturing = false
            return .none
            
        case let .updateCaptureAvailability(isAvailable):
            state.isCaptureAvailable = isAvailable
            return .none
            
            // MARK: UI
            
        case .photoDetailsTapped:
            guard !state.allPhotos.isEmpty else {
                return .none
            }
            
            state.isPhotoDetailsPresented = true
            return .none
            
        case .closePhotoDetails:
            state.isPhotoDetailsPresented = false
            return .none
            
        case .toggleCameraSettings:
            state.isCameraSettingsPresented.toggle()
            return .none
            
            // MARK: Gestures
            
        case let .pinchZoomChanged(scale):
            let delta = scale / state.lastZoomScale
            state.lastZoomScale = scale
            
            return .task { [camera] in
                await camera.applyPinchZoom(delta: delta)
                let newZoomFactor = await camera.zoomFactor
                return .updateZoomFactor(newZoomFactor)
            }
            
        case .pinchZoomEnded:
            state.lastZoomScale = 1.0
            return .none
            
        case let .updateZoomFactor(factor):
            state.currentZoomFactor = factor
            return .none
            
        case let .tapToFocus(focusPoint):
            guard !state.isAutoFocusEnabled else {
                return .none
            }
            
            return .task { [camera] in
                await camera.focusOnPoint(focusPoint)
                return .none
            }
            
        case .showToast:
            state.showToast = true
            return .none
            
        case .hideToast:
            state.showToast = false
            return .none
            
            // MARK: - Advanced Features
            
        case .toggleTorch:
            state.isTorchOn.toggle()
            
            return .task { [camera, isTorchOn = state.isTorchOn] in
                if isTorchOn {
                    await camera.turnOnTorch()
                } else {
                    await camera.turnOffTorch()
                }
                return .none
            }
            
        case .toggleAutoFocus:
            state.isAutoFocusEnabled.toggle()
            return .none
            
        case .toggleDocumentDetection:
            state.isDocumentDetectionEnabled.toggle()
            
            // TODO: 이 로직 좀 더 손봐야함
            if state.isDocumentDetectionEnabled {
                if !state.isVisionProcessorInitialized {
                    camera.enableVisionAnalysis()
                    state.isVisionProcessorInitialized = true
                }
                camera.getDocumentDetectionStream()
                return .send(.startDocumentDetectionStream)
            } else {
                camera.getDocumentDetectionStream()
                state.documentDetection = nil
                return .none
            }
            
        case .toggleLensSmudgeDetection:
            state.isLensSmudgeDetectionEnabled.toggle()
            
            // TODO: 이 로직 좀 더 손봐야함
            if state.isLensSmudgeDetectionEnabled {
                if !state.isVisionProcessorInitialized {
                    camera.enableVisionAnalysis()
                    state.isVisionProcessorInitialized = true
                }
                camera.getLensSmudgeStream()
                return .send(.startLensSmudgeStream)
            } else {
                camera.getLensSmudgeStream()
                state.lensSmudgeDetection = nil
                return .none
            }
            
        case .visionProcessorInitialized:
            state.isVisionProcessorInitialized = true
            return .none
            
        case .startDocumentDetectionStream:
            return .init { [camera] downstream in
                _ = Task {
                    guard let stream = await camera.getDocumentDetectionStream() else {
                        return
                    }
                    
                    for await result in stream {
                        downstream(.updateDocumentDetection(result))
                    }
                }
            }
            
        case .startLensSmudgeStream:
            return .init { [camera] downstream in
                _ = Task {
                    guard let stream = await camera.getLensSmudgeStream() else {
                        return
                    }
                    
                    for await result in stream {
                        downstream(.updateLensSmudgeDetection(result))
                    }
                }
            }
            
        case let .updateDocumentDetection(result):
            state.documentDetection = result
            return .none
            
        case let .updateLensSmudgeDetection(result):
            state.lensSmudgeDetection = result
            return .none
        }
    }
}
