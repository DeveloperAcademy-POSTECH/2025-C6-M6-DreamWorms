////
////  CameraService.swift
////  SUSA24-iOS
////
////  Created by taeni on 11/5/25.
////
//
//@preconcurrency import AVFoundation
//import UIKit
//
//// Swift 6.0 이상에서 Sendable 경고 해결
//extension AVCapturePhotoOutput: @unchecked @retroactive Sendable {}
//extension AVCaptureSession: @unchecked @retroactive Sendable {}
//
//actor CameraService {
//    
//    nonisolated let session: AVCaptureSession?
//    private var output: AVCapturePhotoOutput?
//    private var videoDeviceInput: AVCaptureDeviceInput?
//    
//    init() {
//        session = AVCaptureSession()
//        session?.sessionPreset = .photo
//    }
//    
//    // MARK: - Session Setup
//    func configure() async throws {
//        guard let session = session else { return }
//        
//        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
//        guard let camera = device else { throw CameraError.cameraUnavailable }
//        
//        let input = try AVCaptureDeviceInput(device: camera)
//        if session.canAddInput(input) {
//            session.addInput(input)
//            videoDeviceInput = input
//        }
//        
//        let photoOutput = AVCapturePhotoOutput()
//        if session.canAddOutput(photoOutput) {
//            session.addOutput(photoOutput)
//            self.output = photoOutput
//        }
//        
//        session.startRunning()
//    }
//    
//    // MARK: - Capture Photo
//    @MainActor
//    func capturePhoto() async throws -> Data {
//        guard let output = await output else { throw CameraError.captureFailed }
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            Task { @MainActor in
//                let delegate = PhotoCaptureDelegate { result in
//                    continuation.resume(with: result)
//                }
//                let settings = AVCapturePhotoSettings()
//                output.capturePhoto(with: settings, delegate: delegate)
//            }
//        }
//    }
//    
//    // MARK: - Session Getter
//    func getSession() -> AVCaptureSession? {
//        return session
//    }
//    
//    // MARK: - Errors
//    enum CameraError: Error {
//        case cameraUnavailable
//        case captureFailed
//    }
//}
//
//
//extension CameraService {
//    
//    // MARK: - Session Control
//    func stop() {
//        if session?.isRunning ?? false {
//            session?.stopRunning()
//        }
//    }
//    
//    // MARK: - Get Video Device
//    func getVideoDevice() -> AVCaptureDevice? {
//        return videoDeviceInput?.device
//    }
//    
//    // MARK: - High Quality Configuration
//    func configureForHighQuality() throws {
//        guard let output = output else { throw CameraError.captureFailed }
//        
//        if let device = videoDeviceInput?.device {
//            try enableContinuousAutoFocus(on: device)
//        }
//    }
//}
//
//
//// PhotoCaptureDelegate 클래스 정의 부분 수정
//private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
//    
//    private let completion: @Sendable (Result<Data, Error>) -> Void
//    
//    nonisolated init(completion: @escaping @Sendable (Result<Data, Error>) -> Void) {
//        self.completion = completion
//        super.init()
//    }
//    
//    func photoOutput(
//        _ output: AVCapturePhotoOutput,
//        didFinishProcessingPhoto photo: AVCapturePhoto,
//        error: Error?
//    ) {
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//        
//        guard let data = photo.fileDataRepresentation() else {
//            completion(.failure(CameraService.CameraError.captureFailed))
//            return
//        }
//        
//        completion(.success(data))
//    }
//}
//
//extension CameraService {
//
//    /// 특정 지점에 포커스 및 노출 설정
//    /// - Parameter point: 포커스를 맞추려는 지점 (0.0 ~ 1.0 범위의 normalized coordinates)
//    /// - Throws: 디바이스 설정 실패 또는 카메라를 사용할 수 없는 경우
//    func setFocus(at point: CGPoint) throws {
//        guard let device = videoDeviceInput?.device else {
//            throw CameraError.cameraUnavailable
//        }
//
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
//    /// 화면 중앙에 자동 포커스 및 노출 설정
//    /// - Throws: 디바이스 설정 실패 또는 카메라를 사용할 수 없는 경우
//    func setAutoFocusToCenterAndExpose() throws {
//        let centerPoint = CGPoint(x: 0.5, y: 0.5)
//        try setFocus(at: centerPoint)
//    }
//
//    /// 연속 자동 포커스 및 노출 활성화
//    /// - Throws: 디바이스 설정 실패 또는 카메라를 사용할 수 없는 경우
//    func enableContinuousAutoFocus() throws {
//        guard let device = videoDeviceInput?.device else {
//            throw CameraError.cameraUnavailable
//        }
//
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
