//
//  CameraFrameProvider.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

@preconcurrency import AVFoundation

extension CVImageBuffer: @unchecked @retroactive Sendable {}

// MARK: - Delegate Conformance
extension CameraFrameProvider: AVCaptureVideoDataOutputSampleBufferDelegate {}

/// 카메라 프레임을 스트림으로 제공하고 관리합니다.
/// preview에 보여주고 추후 비전 처리될 프레임을 관리합니다.
final class CameraFrameProvider: NSObject {
    private(set) var frameStream: AsyncStream<CVImageBuffer>?
    private var frameContinuation: AsyncStream<CVImageBuffer>.Continuation?
    
    /// 프레임 스트림을 설정합니다.
    func setupFrameStreams() {
        frameStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.frameContinuation = continuation
        }
    }
    
    /// 프레임 스트림을 정리합니다.
    func cleanupFrameStreams() {
        frameContinuation?.finish()
    }
    
    func yieldFrame(_ imageBuffer: CVImageBuffer) {
        frameContinuation?.yield(imageBuffer)
    }
}

extension CameraFrameProvider {
    /// 비디오 프레임이 캡처되었을 때 호출되는 메서드
    /// - Parameters:
    ///   - output: 프레임을 캡처한 AVCaptureOutput
    ///   - sampleBuffer: 캡처된 프레임 데이터
    ///   - connection: 캡처 연결 정보
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard sampleBuffer.isValid, let imageBuffer = sampleBuffer.imageBuffer else { return }
        
        Task { @MainActor in
            self.yieldFrame(imageBuffer)
        }
    }
}
