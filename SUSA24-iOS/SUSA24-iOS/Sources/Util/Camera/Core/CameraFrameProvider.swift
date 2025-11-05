//
//  CameraFrameProvider.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

@preconcurrency import AVFoundation

/// 카메라 프레임을 스트림으로 제공하고 관리합니다.
/// preview에 보여주고 추후 비전에 처리될 프레임을 관리합니다.

extension CVImageBuffer: @unchecked @retroactive Sendable {}

/// 카메라 프레임을 스트림으로 제공하고 관리합니다.
final class CameraFrameProvider: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
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
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard sampleBuffer.isValid, let imageBuffer = sampleBuffer.imageBuffer else { return }
        
        Task { @MainActor in
            self.frameContinuation?.yield(imageBuffer)
        }
    }
}

