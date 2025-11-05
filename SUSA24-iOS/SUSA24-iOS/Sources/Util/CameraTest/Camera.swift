/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The interface to the features of the camera.
*/

import SwiftUI

/// An object that provides the interface to the features of the camera.
@Observable
final class Camera {
    
    /// An enumeration that describes the current status of the camera.
    enum CameraStatus {
        /// The initial status upon creation.
        case unknown
        /// A status that indicates a person disallows access to the camera or microphone.
        case unauthorized
        /// A status that indicates the camera failed to start.
        case failed
        /// A status that indicates the camera is successfully running.
        case running
        /// A status that indicates higher-priority media processing is interrupting the camera.
        case interrupted
    }
    
    /// The current status of the camera, such as unauthorized, running, or failed.
    private(set) var status = CameraStatus.unknown
    
    /// An object that provides the connection between the capture session and the video preview layer.
    var previewSource: PreviewSource { captureService.previewSource }
    
    /// An object that manages the app's capture functionality.
    private let captureService = CaptureService()
    
    // MARK: - Starting the camera
    /// Start the camera and begin the stream of data.
    func start() async {
        // Verify that the person authorizes the app to use device cameras and microphones.
        guard await captureService.isAuthorized else {
            status = .unauthorized
            return
        }
        do {
            // Start the capture service to start the flow of data.
            try await captureService.start()
            status = .running
        } catch {
            print("Failed to start capture service. \(error)")
            status = .failed
        }
    }

    // MARK: - Photo capture
    
    /// Capture a photo.
    func capturePhoto() async throws -> Data {
        try await captureService.capturePhoto()
    }
}
