/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Provides an asynchronous wrapper for capturing photos.
*/

import AVFoundation

enum PhotoCaptureError: Error {
    case noPhotoData
}

/// An enumeration that defines the activity states the capture service supports.
///
/// This type provides feedback to the UI regarding the active status of the `CaptureService` actor.
enum CaptureActivity {
    case idle
    /// A status that indicates the capture service is performing photo capture.
    case capturing
}

/// An object that manages a photo capture output to perform take photographs.
final class PhotoCapture {
    
    /// A value that indicates the current state of photo capture.
    @Published private(set) var captureActivity: CaptureActivity = .idle
    
    /// The capture output type for this service.
    let output = AVCapturePhotoOutput()
    
    // MARK: - Capture a photo.
    
    /// The app calls this method when the user taps the photo capture button.
    func capturePhoto() async throws -> Data {
        // Wrap the delegate-based capture API in a continuation to use it in an async context.
        try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureDelegate(continuation: continuation)
            monitorProgress(of: delegate)
            // Capture a new photo with default settings.
            let settings = AVCapturePhotoSettings()
            output.capturePhoto(with: settings, delegate: delegate)
        }
    }
    
    /// Monitors the progress of a photo capture delegate.
    ///
    /// The `PhotoCaptureDelegate` produces an asynchronous stream of values that indicate its current activity.
    /// The app propagates the activity values up to the view tier so the UI can update accordingly.
    private func monitorProgress(of delegate: PhotoCaptureDelegate, isolation: isolated (any Actor)? = #isolation) {
        Task {
            _ = isolation
            // Asynchronously monitor the activity of the delegate while the system performs capture.
            for await activity in delegate.activityStream {
                /// More than one activity value for the delegate may report that `isLivePhoto` is `true`.
                /// Only increment/decrement the count when the value changes from its previous state.
                captureActivity = activity
            }
        }
    }
}

typealias PhotoContinuation = CheckedContinuation<Data, Error>

// MARK: - A photo capture delegate to process the captured photo.

/// An object that adopts the `AVCapturePhotoCaptureDelegate` protocol to respond to photo capture life-cycle events.
///
/// The delegate produces a stream of events that indicate its current state of processing.
private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    /// A stream of capture activity values that indicate the current state of progress.
    let activityStream: AsyncStream<CaptureActivity>
    private let activityContinuation: AsyncStream<CaptureActivity>.Continuation
    
    private let continuation: PhotoContinuation
    private var photoData: Data?
    
    /// Creates a new delegate object with the checked continuation to call when processing is complete.
    init(continuation: PhotoContinuation) {
        self.continuation = continuation
        
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: CaptureActivity.self)
        self.activityStream = activityStream
        self.activityContinuation = activityContinuation
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        activityContinuation.yield(.capturing)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        defer {
            /// Finish the continuation to terminate the activity stream.
            activityContinuation.finish()
        }
        
        // If an error occurs, resume the continuation by throwing an error, and return.
        if let error {
            continuation.resume(throwing: error)
            return
        }
        
        // If the app captures no photo data, resume the continuation by throwing an error, and return.
        guard let photoData else {
            continuation.resume(throwing: PhotoCaptureError.noPhotoData)
            return
        }
        
        // Return the photo object.
        continuation.resume(returning: photoData)
    }
}
