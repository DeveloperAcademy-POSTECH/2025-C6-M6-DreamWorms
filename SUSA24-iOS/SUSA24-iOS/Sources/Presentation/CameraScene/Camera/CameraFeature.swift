//
//  CameraFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/31/25.
//

import SwiftUI
import UIKit

struct CameraFeature: DWReducer {
    
    // MARK: - Dependency Injection
    
    private let cameraManager: CameraModel
    
    init(cameraManager: CameraModel) {
        self.cameraManager = cameraManager
    }
    
    // MARK: - State
    
    struct State: DWState {
        /// 촬영된 사진의 개수
        var photoCount: Int = 0
        
        /// 마지막으로 촬영된 사진의 썸네일 (UIImage?)
        var lastThumbnail: UIImage? = nil
        
        /// 모든 촬영된 사진
        var allPhotos: [CapturedPhoto] = []
        
        /// 카메라 프리뷰 소스
        var previewSource: PreviewSource
        
        /// 카메라 상태
        var cameraStatus: CameraStatus = .notInitialized
        
        /// 사진 촬영이 가능한 상태인지 여부
        var isCaptureAvailable: Bool = true
        
        /// 사진 상세보기 화면 표시 여부
        var isPhotoDetailsPresented: Bool = false
        
        // MARK: - Initialization
        
        init(previewSource: PreviewSource) {
            self.previewSource = previewSource
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 화면이 나타날 때 발생하는 액션
        case onAppear
        
        /// 화면이 사라질 때 발생하는 액션
        case onDisappear
        
        /// 사진 촬영 버튼 탭
        case capturePhotoTapped
        
        /// 사진 상세보기 뷰 이동
        case showPhotoDetails
        
        /// 사진 상세보기 뷰 닫기
        case closePhotoDetails
        
        /// 카메라 상태를 업데이트하는 액션
        case setCameraStatus(CameraStatus)
        
        /// 사진 개수를 업데이트하는 액션
        case updatePhotoCount(Int)
        
        /// 섬네일을 업데이트하는 액션
        case updateThumbnail(UIImage?)
        
        /// 모든 사진을 업데이트하는 액션
        case updateAllPhotos([CapturedPhoto])
        
        /// 사진 촬영 가능 상태를 업데이트하는 액션
        case updateCaptureAvailability(Bool)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            return .task { [cameraManager] in
                // 카메라 시작
                await cameraManager.start()
                return .setCameraStatus(.running)
            }
            
        case .onDisappear:
            return .task { [cameraManager] in
                await cameraManager.stop()
                return .setCameraStatus(.stopped)
            }
            
        case .capturePhotoTapped:
            guard state.isCaptureAvailable else {
                return .none
            }
            
            return .task { [cameraManager] in
                do {
                    let photo = try await cameraManager.capturePhoto()
                    let photoCount = await cameraManager.photoCount
                    let thumbnail = await cameraManager.lastThumbnail
                    let allPhotos = await cameraManager.getAllPhotos()
                    
                    // 순차적으로 state 업데이트
                    var actions: [Action] = [
                        .updatePhotoCount(photoCount),
                        .updateThumbnail(thumbnail),
                        .updateAllPhotos(allPhotos)
                    ]
                    
                    // 최대 10장 체크
                    // TODO: toast 띄우기
                    if photoCount >= 10 {
                        actions.append(.updateCaptureAvailability(false))
                    }
                    
                    return actions.first ?? .none
                } catch {
                    print("사진 촬영 실패: \(error.localizedDescription)")
                    return .none
                }
            }
            
        case .showPhotoDetails:
            guard !state.allPhotos.isEmpty else { return .none }
            state.isPhotoDetailsPresented = true
            return .none
            
        case .closePhotoDetails:
            state.isPhotoDetailsPresented = false
            return .none
            
        case .setCameraStatus(let status):
            state.cameraStatus = status
            return .none
            
        case .updatePhotoCount(let count):
            state.photoCount = count
            return .none
            
        case .updateThumbnail(let image):
            state.lastThumbnail = image
            return .none
            
        case .updateAllPhotos(let photos):
            state.allPhotos = photos
            return .none
            
        case .updateCaptureAvailability(let isAvailable):
            state.isCaptureAvailable = isAvailable
            return .none
        }
    }
}
