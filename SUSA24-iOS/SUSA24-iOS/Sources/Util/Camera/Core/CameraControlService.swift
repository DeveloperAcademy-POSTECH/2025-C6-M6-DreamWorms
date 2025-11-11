//
//  CameraControlService.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import AVFoundation

/// TODO: 전체적으로 에러처리 해야함, print 제거 필요
/// 카메라 디바이스를 제어하는 액터 (zoom, torch, focus 등)
actor CameraControlService {
    private(set) var device: AVCaptureDevice?
    private(set) var zoomFactor: CGFloat = 1.0
    private(set) var isTorchOn: Bool = false
    
    private let minimumZoom: CGFloat = 0.5
    private let maximumZoom: CGFloat = 12.0
    
    // MARK: - Device Setup
    
    /// 후면 카메라를 선택합니다. 가능한 경우 듀얼 와이드 카메라를 우선시합니다.
    func selectBackCamera() {
        // Dual Wide 카메라를 먼저 시도
        if let dualWideCamera = AVCaptureDevice.default(
            .builtInDualWideCamera,
            for: .video,
            position: .back
        ) {
            device = dualWideCamera
            return
        }
        
        // 트리플 카메라 시도
        if let tripleCamera = AVCaptureDevice.default(
            .builtInTripleCamera,
            for: .video,
            position: .back
        ) {
            device = tripleCamera
            return
        }
        
        // 기본 와이드 앵글 카메라로 폴백
        device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        )
        
        if device != nil {
            _ = try? setupFocusMode()
        }
    }
    
    /// 프론트 카메라를 선택합니다.
    /// 현재는 사용안함
    func selectFrontCamera() {
        device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        )
        
        if device != nil {
            _ = try? setupFocusMode()
        }
    }
    
    // MARK: - Zoom Control
    
    /// 지정된 줌 팩터를 가져와 줌을 설정합니다.
    /// - Parameter factor: 줌 팩터 (0.5 ~ 12.0)
    /// - Returns: 실제 설정된 줌 팩터
    /// 디폴트는 1.0
    func setZoom(to factor: CGFloat) -> CGFloat {
        guard let device else { return 1.0 }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            let clampedZoom = max(minimumZoom, min(factor, maximumZoom))
            device.videoZoomFactor = clampedZoom
            zoomFactor = clampedZoom
            
            return clampedZoom
        } catch {
            print("설정 실패: \(error.localizedDescription)")
            return zoomFactor
        }
    }
    
    /// Pinch 제스처로 상대적 줌을 조절합니다.
    /// - Parameter delta: 줌 변경 배수
    /// - Returns: 실제 설정된 줌 팩터
    func applyPinchZoom(delta: CGFloat) -> CGFloat {
        let newZoom = zoomFactor * delta
        return setZoom(to: newZoom)
    }
    
    // MARK: - Torch Control
    
    /// 토치(손전등)를 켭니다.
    /// - Returns: 성공 여부
    func turnOnTorch() -> Bool {
        guard let device, device.hasTorch else { return false }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.torchMode = .on
            isTorchOn = true
            return true
        } catch {
            print("토치 켜기 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 토치(손전등)를 끕니다.
    /// - Returns: 성공 여부
    func turnOffTorch() -> Bool {
        guard let device, device.hasTorch else { return false }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.torchMode = .off
            isTorchOn = false
            return true
        } catch {
            print("토치 끄기 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 토치를 토글합니다.
    /// - Returns: 토글 후의 토치 켜짐 여부 (isTorchOn)
    func toggleTorch() -> Bool {
        if isTorchOn {
            // 끄기 시도: turnOffTorch()는 성공 여부를 반환하지만,
            // 토글 함수의 목적은 isTorchOn 상태를 업데이트하는 것.
            _ = turnOffTorch()
        } else {
            // 켜기 시도: turnOnTorch()는 성공 여부를 반환.
            _ = turnOnTorch()
        }
        
        // 최종 상태를 반환합니다.
        return isTorchOn
    }
    
    // MARK: - Focus Control
    
    /// 연속 자동 포커스를 설정합니다.
    private func setupFocusMode() throws {
        guard let device else { return }
        
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    /// 특정 포인트에 포커스를 맞춥니다.
    /// - Parameters:
    ///   - point: 뷰에서의 포인트 (0~1 정규화 좌표)
    func focusOnPoint(_ point: CGPoint) {
        guard let device else { return }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
        } catch {
            print("포커스 설정 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Utility
    
    /// 디바이스의 줌 가능 범위를 반환합니다.
    func getZoomRange() -> ClosedRange<CGFloat> {
        minimumZoom ... maximumZoom
    }
}
