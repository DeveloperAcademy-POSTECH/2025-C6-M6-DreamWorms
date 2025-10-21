//
//  CameraModel.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/21/25.
//

@preconcurrency import AVFoundation
import SwiftUI
import Vision

@MainActor
@Observable
final class CameraModel: NSObject {
    private(set) var frame: CVImageBuffer?

    private let privacyService = PrivacyService()
    private let captureService = CaptureService()
    private let deviceService = DeviceService()
    private let visionService = VisionService()

    func start() async {
        await privacyService.fetchStatus()
        await deviceService.fetchVideoDevice()
        guard let videoDevice = await deviceService.videoDevice else { return }
        await captureService.configureSession(
            device: videoDevice,
            delegate: self
        )
    }

    func recognizeAddressesFromCurrentFrame() async throws -> (fullText: String, addresses: [String]) {
        guard let pixelBuffer = frame else {
            struct NoFrame: Error {}
            throw NoFrame()
        }
        return try await visionService.recognizeAddresses(from: pixelBuffer)
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from _: AVCaptureConnection
    ) {
        if sampleBuffer.isValid, let imageBuffer = sampleBuffer.imageBuffer {
            Task { @MainActor in
                self.frame = imageBuffer
            }
        }
    }
}
