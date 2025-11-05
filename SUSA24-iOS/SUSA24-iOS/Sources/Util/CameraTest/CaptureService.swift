/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Manages a capture session and its inputs and outputs.
*/

import Foundation
import AVFoundation
import Combine

enum CameraError: Error {
    case addInputFailed
    case addOutputFailed
    case deviceUnavailable
}

/// An actor that manages the capture pipeline, which includes the capture session, device inputs, and capture outputs.
/// The app defines it as an `actor` type to ensure that all camera operations happen off of the `@MainActor`.
actor CaptureService {
    
    /// A type that connects a preview destination with the capture session.
    nonisolated let previewSource: PreviewSource
    
    // The app's capture session.
    private let captureSession = AVCaptureSession()
    
    // An object that manages the app's photo capture behavior.
    private let photoCapture = PhotoCapture()
    
    // The video input for the currently selected device camera.
    private var activeVideoInput: AVCaptureDeviceInput?
    
    // A Boolean value that indicates whether the actor finished its required configuration.
    private var isSetUp = false
    
    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: "com.example.apple-samplecode.DocumentRecognizer.sessionQueue")
    
    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }
    
    init() {
        // Create a source object to connect the preview view with the capture session.
        previewSource = DefaultPreviewSource(session: captureSession)
    }
    
    // MARK: - Authorization
    /// A Boolean value that indicates whether a person authorizes this app to use
    /// device cameras and microphones. If they haven't previously authorized the
    /// app, querying this property prompts them for authorization.
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            // Determine whether a person previously authorized camera access.
            var isAuthorized = status == .authorized
            // If the system hasn't determined their authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    // MARK: - Capture session life cycle
    func start() async throws {
        // Exit early if not authorized or the session is already running.
        guard await isAuthorized, !captureSession.isRunning else { return }
        // Configure the session and start it.
        try setUpSession()
        captureSession.startRunning()
    }
    
    // MARK: - Capture setup
    // Performs the initial capture session configuration.
    private func setUpSession() throws {
        // Return early if already set up.
        guard !isSetUp else { return }
        
        // Retrieve the default camera.
        guard let defaultCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraError.deviceUnavailable
        }

        // Add inputs for the default camera and microphone devices.
        activeVideoInput = try addInput(for: defaultCamera)

        // Configure the session preset based on the current capture mode.
        captureSession.sessionPreset = .photo
        // Add the photo capture output as the default output type.
        try addOutput(photoCapture.output)
        
        isSetUp = true
    }

    // Adds an input to the capture session to connect the specified capture device.
    @discardableResult
    private func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        let input = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            throw CameraError.addInputFailed
        }
        return input
    }
    
    // Adds an output to the capture session to connect the specified capture device, if allowed.
    private func addOutput(_ output: AVCaptureOutput) throws {
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            throw CameraError.addOutputFailed
        }
    }
    
    // The device for the active video input.
    private var currentDevice: AVCaptureDevice {
        guard let device = activeVideoInput?.device else {
            fatalError("No device found for current video input.")
        }
        return device
    }
    
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        // Access the capture session's connected preview layer.
        guard let previewLayer = captureSession.connections.compactMap({ $0.videoPreviewLayer }).first else {
            fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
        }
        return previewLayer
    }
    
    func capturePhoto() async throws -> Data {
        try await photoCapture.capturePhoto()
    }
}
