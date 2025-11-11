//
//  PhotoDetailsFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/31/25.
//

import SwiftUI

struct PhotoDetailsFeature: DWReducer {
    
    // MARK: - Dependencies
    
    // CameraView 연동
    // TODO: 다른 방식 고안 필요
    private let camera: CameraModel
    
    init(camera: CameraModel) {
        self.camera = camera
    }
    
    // MARK: - State
    
    struct State: DWState {
        var photos: [CapturedPhoto]
        
        // 현재 이미지 index
        var currentIndex: Int
        
        var shouldDismiss: Bool = false
        
        var currentPhoto: CapturedPhoto? {
            guard !photos.isEmpty, currentIndex < photos.count else { return nil }
            return photos[currentIndex]
        }
        
        var canSwipeLeft: Bool {
            currentIndex > 0
        }
        
        var canSwipeRight: Bool {
            currentIndex < photos.count - 1
        }
        
        init(photos: [CapturedPhoto]) {
            self.photos = photos
            self.currentIndex = 0
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case currentIndexChanged(Int)
        case deleteCurrentPhoto
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
            
        case .currentIndexChanged(let newIndex):
            state.currentIndex = newIndex
            return .none
            
        case .deleteCurrentPhoto:
            guard !state.photos.isEmpty, state.currentIndex < state.photos.count else {
                return .none
            }
            
            // 실제 삭제: CameraModel에서 삭제
            // CameraModel에서 해당 사진 찾아서 삭제
            let photoToDelete = state.photos[state.currentIndex]
            if let indexInCamera = camera.getAllPhotos().firstIndex(where: { $0.id == photoToDelete.id }) {
                camera.deletePhoto(at: indexInCamera)
            }
            
            // State에서도 삭제
            state.photos.remove(at: state.currentIndex)
            
            // 현재 인덱스 조정
            if state.currentIndex >= state.photos.count {
                state.currentIndex = max(0, state.photos.count - 1)
            }
            
            // 모든 사진이 삭제되면 자동으로 dismiss
            if state.photos.isEmpty {
                state.shouldDismiss = true
            }
    
            return .none
        }
    }
}
