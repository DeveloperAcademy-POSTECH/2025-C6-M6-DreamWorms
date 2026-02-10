//
//  CameraPermissionService.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import AVFoundation

/// 카메라 권한을 관리하는 액터
actor CameraPermissionService {
    private(set) var isCameraAuthorized: Bool = false
    
    /// 카메라 권한을 확인하고 요청
    func requestCameraAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            isCameraAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        default:
            isCameraAuthorized = false
        }
        
        return isCameraAuthorized
    }
}
