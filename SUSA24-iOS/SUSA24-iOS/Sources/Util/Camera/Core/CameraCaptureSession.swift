//
//  CameraCaptureSession.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import AVFoundation

/// 카메라 캡처 세션을 관리하는 액터
actor CameraCaptureSession {
    private var session: AVCaptureSession?
    private let sessionQueue = DispatchSerialQueue(label: "com.dreamworms.susa24.camera.sessionQueue")
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }
    
    // MARK: - Session Lifecycle
    
    /// 캡처 세션을 구성하고 시작합니다.
    /// - Parameters:
    ///   - captureSession: 사용할 AVCaptureSession
    ///   - device: 사용할 AVCaptureDevice
    ///   - sampleBufferDelegate: 프레임 수신 델리게이트
    /// - Throws: 세션 구성 실패 시 에러
    func configureAndStart(
        captureSession: AVCaptureSession,
        with device: AVCaptureDevice,
        sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate
    ) throws {
        let newSession = captureSession
        
        // 입력 추가
        let input = try AVCaptureDeviceInput(device: device)
        guard newSession.canAddInput(input) else {
            throw CameraSessionError.failedToAddInput
        }
        newSession.addInput(input)
        
        // 출력 추가
        let output = AVCaptureVideoDataOutput()
        guard newSession.canAddOutput(output) else {
            throw CameraSessionError.failedToAddOutput
        }
        newSession.addOutput(output)
        
        // 세션 프리셋 설정 (1920x1080)
        if newSession.canSetSessionPreset(.hd1920x1080) {
            newSession.sessionPreset = .hd1920x1080
        }
        
        // 연결 설정
        if let connection = output.connection(with: .video) {
            connection.videoRotationAngle = 90
            
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .standard
            }
        }
        
        // 델리게이트 설정
        output.setSampleBufferDelegate(
            sampleBufferDelegate,
            queue: sessionQueue
        )
        
        // 세션 시작
        session = newSession
        newSession.startRunning()
    }
    
    /// 캡처 세션을 중지하고 정리합니다.
    func stopAndClean() {
        session?.stopRunning()
        session = nil
    }
    
    /// 세션 일시정지 (입력 초기화 X)
    func pause() {
        session?.stopRunning()
    }
    
    /// 세션 재개 (세션이 살아있을 때만)
    func resume() {
        session?.startRunning()
    }
    
    /// 세션이 실행 중인지 확인합니다.
    func isRunning() -> Bool {
        session?.isRunning ?? false
    }
    
    func pause() {
        session?.stopRunning()
    }

    func resume() {
        session?.startRunning()
    }
    
    /// 사진 촬영 출력을 세션에 추가합니다.
    /// - Parameter photoOutput: 추가할 AVCapturePhotoOutput
    /// - Throws: 추가 실패 시 에러
    func addPhotoOutput(_ photoOutput: AVCapturePhotoOutput) throws {
        guard let session else {
            throw CameraSessionError.sessionNotConfigured
        }
        
        guard session.canAddOutput(photoOutput) else {
            throw CameraSessionError.failedToAddOutput
        }
        
        session.addOutput(photoOutput)
    }
}
