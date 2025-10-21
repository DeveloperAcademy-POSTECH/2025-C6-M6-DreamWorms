//
//  PrivacyService.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/21/25.
//

import AVFoundation

actor PrivacyService {
    var isCamera: Bool = false
    
    func fetchStatus() async {
        isCamera = await checkCameraAuthorization()
    }
    
    private func checkCameraAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            true
        case .notDetermined:
            await AVCaptureDevice.requestAccess(for: .video)
        default:
            false
        }
    }
}
