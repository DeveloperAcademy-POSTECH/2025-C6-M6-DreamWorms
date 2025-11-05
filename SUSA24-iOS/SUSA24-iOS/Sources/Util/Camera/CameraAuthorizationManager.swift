////
////  CameraAuthorizationManager.swift
////  SUSA24-iOS
////
////  Created by taeni on 11/5/25.
////
//
//import AVFoundation
//import UIKit
//import Combine
//
//// MARK: - Camera Authorization
//actor CameraAuthorizationManager {
//    static let shared = CameraAuthorizationManager()
//    
//    func requestCameraAccess() async -> Bool {
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//        
//        switch status {
//        case .authorized:
//            return true
//        case .notDetermined:
//            return await AVCaptureDevice.requestAccess(for: .video)
//        case .denied, .restricted:
//            return false
//        @unknown default:
//            return false
//        }
//    }
//}
//
//// MARK: - Image Manager
//@MainActor
//final class CameraImageManager: ObservableObject {
//    @Published private(set) var images: [UIImage] = []
//    @Published private(set) var lastImage: UIImage?
//    
//    private let maxImages = 10
//    
//    func addImage(_ image: UIImage) {
//        images.append(image)
//        if images.count > maxImages {
//            images.removeFirst()
//        }
//        lastImage = image
//    }
//    
//    func clearAll() {
//        images.removeAll()
//        lastImage = nil
//    }
//}
//
//// MARK: - Camera Focus Manager
//extension CameraService {
//    func setFocus(at point: CGPoint, on device: AVCaptureDevice) throws {
//        try device.lockForConfiguration()
//        defer { device.unlockForConfiguration() }
//        
//        if device.isFocusPointOfInterestSupported {
//            device.focusPointOfInterest = point
//            device.focusMode = .autoFocus
//        }
//        
//        if device.isExposurePointOfInterestSupported {
//            device.exposurePointOfInterest = point
//            device.exposureMode = .autoExpose
//        }
//    }
//    
//    func setAutoFocusToCenterAndExpose(on device: AVCaptureDevice) throws {
//        let centerPoint = CGPoint(x: 0.5, y: 0.5)
//        try setFocus(at: centerPoint, on: device)
//    }
//    
//    func enableContinuousAutoFocus(on device: AVCaptureDevice) throws {
//        try device.lockForConfiguration()
//        defer { device.unlockForConfiguration() }
//        
//        if device.isFocusModeSupported(.continuousAutoFocus) {
//            device.focusMode = .continuousAutoFocus
//        }
//        
//        if device.isExposureModeSupported(.continuousAutoExposure) {
//            device.exposureMode = .continuousAutoExposure
//        }
//    }
//}
