//
//  CameraModel.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

@preconcurrency import AVFoundation
import SwiftUI

/// 카메라의 모든 기능을 통합 관리
@MainActor
@Observable
final class CameraModel: NSObject {
    private let permissionService: CameraPermissionService
    private let controlService: CameraControlService
    private let captureSession: CameraCaptureSession
    private let frameProvider: CameraFrameProvider
    private let photoCaptureService: PhotoCaptureService
    
    // 카메라 세션 nonisolated
    nonisolated let session: AVCaptureSession = AVCaptureSession()
    
    // MARK: - Public State
    
    private(set) var cameraStatus: CameraStatus = .notInitialized
    private(set) var currentFrame: CVImageBuffer?
    private(set) var isRunning: Bool = false
    private(set) var isCameraPaused: Bool = false
    
    // Vision
    var visionProcessor: DocumentDetectionProcessor?
    var isVisionEnabled: Bool = false
    
    // Camera Control
    private(set) var zoomFactor: CGFloat = 1.0
    private(set) var isTorchOn: Bool = false
    
    // Photo Management
    private(set) var lastThumbnail: UIImage?
    private(set) var photoCount: Int = 0
    
    // Preview Source
    var previewSource: PreviewSource {
        DefaultPreviewSource(session: session)
    }
    
    // MARK: - Initialization
    
    override init() {
        self.permissionService = CameraPermissionService()
        self.controlService = CameraControlService()
        self.captureSession = CameraCaptureSession()
        self.frameProvider = CameraFrameProvider()
        self.photoCaptureService = PhotoCaptureService()
        
        super.init()
    }
}

// MARK: - Camera Lifecycle + Control

extension CameraModel {
    /// 카메라를 시작
    func start() async {
        guard cameraStatus == .notInitialized else { return }
        
        cameraStatus = .checking
        
        // 권한 확인
        let hasPermission = await permissionService.requestCameraAuthorization()
        guard hasPermission else {
            cameraStatus = .unauthorized
            return
        }
        
        // 디바이스 선택
        await controlService.selectBackCamera()
        guard let device = await controlService.device else {
            cameraStatus = .failed
            return
        }
        
        // 프레임 스트림 설정
        frameProvider.setupFrameStreams()
        
        // 캡처 세션 시작 (session을 전달)
        do {
            try await captureSession.configureAndStart(
                captureSession: session,
                with: device,
                sampleBufferDelegate: frameProvider
            )
            
            // 사진 촬영 출력 추가
            try await addPhotoCaptureOutput()
            
            cameraStatus = .running
            isRunning = true
            
            Task {
                await self.processDisplayFrames()
            }
        } catch {
            print("카메라 시작 실패: \(error.localizedDescription)")
            cameraStatus = .failed
        }
    }
    
    /// 카메라를 일시정지
    func pauseCamera() {
        isCameraPaused = true
        Task { await captureSession.pause() }
    }

    func resumeCamera() {
        isCameraPaused = false
        Task { await captureSession.resume() }
    }
    
    /// 카메라를 중지
    func stop() async {
        await captureSession.stopAndClean()
        frameProvider.cleanupFrameStreams()
        isRunning = false
        cameraStatus = .stopped
        currentFrame = nil
    }
}

// MARK: - Photo Capture

extension CameraModel {
    /// 사진을 촬영
    func capturePhoto() async throws -> CapturedPhoto {
        let photo = try await photoCaptureService.capturePhoto()
        updatePhotoState()
        return photo
    }
    
    /// 모든 촬영된 사진을 반환
    func getAllPhotos() -> [CapturedPhoto] {
        photoCaptureService.getAllPhotos()
    }
    
    /// 특정 인덱스의 사진을 삭제
    func deletePhoto(at index: Int) {
        photoCaptureService.deletePhoto(at: index)
        updatePhotoState()
    }
    
    /// 모든 사진을 삭제
    func clearAllPhotos() {
        photoCaptureService.clearAllPhotos()
        updatePhotoState()
    }
    
    /// 마지막 사진의 섬네일을 반환
    func getLastThumbnail() -> UIImage? {
        photoCaptureService.getLastThumbnail()
    }
}

// MARK: - Device Zoom, Torch Control, Focus

extension CameraModel {
    /// 줌을 설정 (0.5 ~ 12.0배)
    func setZoom(to factor: CGFloat) async {
        guard !isCameraPaused else { return }
        zoomFactor = await controlService.setZoom(to: factor)
    }
    
    /// Pinch 제스처로 줌을 조절
    func applyPinchZoom(delta: CGFloat) async {
        guard !isCameraPaused else { return }
        zoomFactor = await controlService.applyPinchZoom(delta: delta)
    }
    
    /// 기본 줌 설정 (1.0배)을 적용
    func resetZoom() async {
        await setZoom(to: 1.0)
    }
    
    /// 줌 가능 범위를 반환
    func getZoomRange() async -> ClosedRange<CGFloat> {
        await controlService.getZoomRange()
    }
    
    /// 토치를 토글
    func toggleTorch() async {
        isTorchOn = await controlService.toggleTorch()
    }
    
    /// 토치를 켭니다.
    func turnOnTorch() async {
        let success = await controlService.turnOnTorch()
        if success {
            isTorchOn = true
        }
    }
    
    /// 토치를 끕니다.
    func turnOffTorch() async {
        let success = await controlService.turnOffTorch()
        if success {
            isTorchOn = false
        }
    }
    
    /// 선택한 위치 오토 포커싱
    func focusOnPoint(_ point: CGPoint) async {
        guard !isCameraPaused else { return }
        await controlService.focusOnPoint(point)
    }
}

// MARK: - Frame Stream

extension CameraModel {
    /// 프레임 스트림을 반환
    func getFrameStream() -> AsyncStream<CVImageBuffer>? {
        frameProvider.frameStream
    }
}

// MARK: - Private Methods

extension CameraModel {
    private func addPhotoCaptureOutput() async throws {
        try await captureSession.addPhotoOutput(photoCaptureService.output)
    }
    
    private func processDisplayFrames() async {
        guard let frameStream = frameProvider.frameStream else { return }
        
        for await imageBuffer in frameStream {
            guard !isCameraPaused else { continue }
            currentFrame = imageBuffer
        }
    }
    
    private func updatePhotoState() {
        lastThumbnail = photoCaptureService.getLastThumbnail()
        photoCount = photoCaptureService.getAllPhotos().count
    }
}
