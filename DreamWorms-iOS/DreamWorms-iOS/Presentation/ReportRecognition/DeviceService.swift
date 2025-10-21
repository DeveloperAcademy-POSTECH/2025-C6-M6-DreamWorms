//
//  DeviceService.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/21/25.
//

import AVFoundation

actor DeviceService {
    var videoDevice: AVCaptureDevice?
    
    func fetchVideoDevice() {
        videoDevice = AVCaptureDevice.default(for: .video)!
    }
}
