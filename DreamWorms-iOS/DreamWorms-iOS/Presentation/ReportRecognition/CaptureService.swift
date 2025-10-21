//
//  CaptureService.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/21/25.
//

import AVFoundation

actor CaptureService {
    private var session: AVCaptureSession?
    private let queue = DispatchQueue(label: "sampleBufferQueue")
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?

    func configureSession(
        device: AVCaptureDevice,
        delegate videoDelegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        photoDelegate: AVCapturePhotoCaptureDelegate? = nil
    ) {
        let session = AVCaptureSession()
        self.session = session

        let videoInput = try! AVCaptureDeviceInput(device: device)
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String:
                kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
        ]
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        self.videoOutput = videoOutput

        if let connection = videoOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        videoOutput.setSampleBufferDelegate(videoDelegate, queue: queue)

        if let photoDelegate {
            let photoOutput = AVCapturePhotoOutput()
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
            }
            self.photoOutput = photoOutput
        }

        session.startRunning()
    }

    func startRunning() {
        session?.startRunning()
    }

    func stopRunning() {
        session?.stopRunning()
    }

    func capturePhoto(delegate: AVCapturePhotoCaptureDelegate) {
        guard let photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}
