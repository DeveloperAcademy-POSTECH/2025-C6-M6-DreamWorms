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
struct CameraFeature: DWReducer {
    
    // MARK: - Dependency Injection
    
    private let camera: CameraModel
    
    init(camera: CameraModel) {
        self.camera = camera
    }
    
    // MARK: - State
    
    struct State: DWState {
        
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
        
        // MARK: UI State
        
        /// 사진 상세보기 화면 표시 여부
        var isPhotoDetailsPresented: Bool = false
        
        // MARK: Gesture State
        
        /// Pinch Zoom의 마지막 스케일 값
        var lastZoomScale: CGFloat = 1.0
        
        /// 현재 줌 배율
        var currentZoomFactor: CGFloat = 1.0
        
        // MARK: - Initialization
        
        init(previewSource: PreviewSource) {
            self.previewSource = previewSource
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        
        // MARK: Lifecycle Actions
        
        /// 화면이 나타날 때 발생하는 액션
        case onAppear
        
        /// 화면이 사라질 때 발생하는 액션
        case onDisappear
        
        // MARK: Camera Control Actions
        
        /// 카메라 상태를 업데이트하는 액션
        case setCameraStatus(CameraStatus)
        
        /// 카메라 실행 상태를 업데이트하는 액션
        case setCameraRunning(Bool)
        
        // MARK: Photo Capture Actions
        
        /// 사진 촬영 버튼 탭
        case captureButtonTapped
        
        /// 사진 촬영 완료 후 상태 동기화 시작
        case syncPhotoState
        
        /// 사진 개수를 업데이트하는 액션
        case updatePhotoCount(Int)
        
        /// 섬네일을 업데이트하는 액션
        case updateThumbnail(UIImage?)
        
        /// 모든 사진을 업데이트하는 액션
        case updateAllPhotos([CapturedPhoto])
        
        /// 사진 촬영 가능 상태를 업데이트하는 액션
        case updateCaptureAvailability(Bool)
        
        // MARK: UI Actions
        
        /// 사진 상세보기 버튼 탭
        case photoDetailsTapped
        
        /// 사진 상세보기 화면 닫기
        case closePhotoDetails
        
        // MARK: Gesture Actions

        /// Pinch Zoom 제스처 변경
        case pinchZoomChanged(CGFloat)
        
        /// Pinch Zoom 제스처 종료
        case pinchZoomEnded
        
        /// Tap to Focus
        case tapToFocus(CGPoint)
        
        /// 줌 배율 업데이트
        case updateZoomFactor(CGFloat)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
            
        // MARK: Lifecycle
            
        case .onAppear:
            return .task { [camera] in
                await camera.start()
                let status = await camera.cameraStatus
                return .setCameraStatus(status)
            }
            
        case .onDisappear:
            return .task { [camera] in
                await camera.stop()
                return .setCameraStatus(.stopped)
            }
            
        // MARK: Camera Control
            
        case .setCameraStatus(let status):
            state.cameraStatus = status
            
            // running 상태면 isRunning도 업데이트
            if status == .running {
                return .task { [camera] in
                    let isRunning = await camera.isRunning
                    return .setCameraRunning(isRunning)
                }
            }
            return .none
            
        case .setCameraRunning(let isRunning):
            state.isRunning = isRunning
            return .none
            
        // MARK: Photo Capture
            
        case .captureButtonTapped:
            guard state.isCaptureAvailable else {
                return .none
            }
            
            return .task { [camera] in
                do {
                    _ = try await camera.capturePhoto()
                    return .syncPhotoState
                } catch {
                    return .none
                }
            }
            
        // 의문 : 3가지의 동작인데, downstream 으로 처리하는게 나은가? 아니면 이대로? (어차피 downstream이 감싸고 있음)
        case .syncPhotoState:
            // 첫 번째: photoCount 업데이트
            return .task { [camera] in
                let photoCount = await camera.photoCount
                return .updatePhotoCount(photoCount)
            }
            
        case .updatePhotoCount(let count):
            state.photoCount = count
            
            // 10장 제한 체크
            if count >= 10 {
                state.isCaptureAvailable = false
            }
            
            // 두 번째: thumbnail 업데이트
            return .task { [camera] in
                let thumbnail = await camera.lastThumbnail
                return .updateThumbnail(thumbnail)
            }
            
        case .updateThumbnail(let image):
            state.lastThumbnail = image
            
            // 세 번째: allPhotos 업데이트
            return .task { [camera] in
                let allPhotos = await camera.getAllPhotos()
                return .updateAllPhotos(allPhotos)
            }
            
        case .updateAllPhotos(let photos):
            state.allPhotos = photos
            return .none
            
        case .updateCaptureAvailability(let isAvailable):
            state.isCaptureAvailable = isAvailable
            return .none
            
        // MARK: UI
            
        case .photoDetailsTapped:
            guard !state.allPhotos.isEmpty else {
                // 토스트 띄움
                return .none
            }
            
            state.isPhotoDetailsPresented = true
            return .none
            
        case .closePhotoDetails:
            state.isPhotoDetailsPresented = false
            return .none
            
        // MARK: Gestures
            
        case .pinchZoomChanged(let scale):
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
            
        case .updateZoomFactor(let factor):
            state.currentZoomFactor = factor
            return .none
            
        case .tapToFocus(let focusPoint):
            return .task { [camera] in
                await camera.focusOnPoint(focusPoint)
                return .none
            }
        }
    }
}
