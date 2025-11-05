//
//  PhotoCaptureService.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//


import AVFoundation
import UIKit

/// 사진 촬영 및 관리를 담당합니다. (최대 10장)
@Observable
final class PhotoCaptureService: NSObject, AVCapturePhotoCaptureDelegate {
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.camera.photoCaptureQueue")
    
    private(set) var capturedPhotos: [CapturedPhoto] = []
    private(set) var lastThumbnail: UIImage?
    private(set) var isCaptureAvailable: Bool = true
    
    private let maxPhotosLimit = 10
    private var continuations: [CheckedContinuation<CapturedPhoto, Error>] = []
    
    // MARK: - Public API
    
    /// 사진 촬영 출력 객체를 반환합니다.
    var output: AVCapturePhotoOutput {
        photoOutput
    }
    
    /// 사진을 촬영합니다.
    /// - Returns: 촬영된 사진 데이터
    /// - Throws: 촬영 실패 시 에러
    func capturePhoto() async throws -> CapturedPhoto {
        guard isCaptureAvailable else {
            throw PhotoCaptureError.maxPhotosExceeded
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    /// 마지막으로 촬영된 사진의 섬네일을 반환합니다.
    func getLastThumbnail() -> UIImage? {
        lastThumbnail
    }
    
    /// 촬영된 모든 사진을 반환합니다.
    func getAllPhotos() -> [CapturedPhoto] {
        capturedPhotos
    }
    
    /// 특정 인덱스의 사진을 삭제합니다.
    func deletePhoto(at index: Int) {
        guard index >= 0, index < capturedPhotos.count else { return }
        capturedPhotos.remove(at: index)
        updateCapturability()
    }
    
    /// 모든 사진을 삭제합니다.
    func clearAllPhotos() {
        capturedPhotos.removeAll()
        lastThumbnail = nil
        updateCapturability()
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil else {
            Task {
                let continuation = await self.getNextContinuation()
                continuation?.resume(throwing: error ?? PhotoCaptureError.captureFailure)
            }
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            Task {
                let continuation = await self.getNextContinuation()
                continuation?.resume(throwing: PhotoCaptureError.noPhotoData)
            }
            return
        }
        
        Task {
            await self.addCapturedPhoto(photoData)
        }
    }
    
    // MARK: - Private Methods
    
    private func addCapturedPhoto(_ photoData: Data) async {
        guard capturedPhotos.count < maxPhotosLimit else {
            let continuation = await getNextContinuation()
            continuation?.resume(throwing: PhotoCaptureError.maxPhotosExceeded)
            return
        }
        
        let capturedPhoto = CapturedPhoto(
            id: UUID(),
            data: photoData,
            timestamp: Date(),
            thumbnail: createThumbnail(from: photoData)
        )
        
        capturedPhotos.append(capturedPhoto)
        lastThumbnail = capturedPhoto.thumbnail
        updateCapturability()
        
        let continuation = await getNextContinuation()
        continuation?.resume(returning: capturedPhoto)
    }
    
    private func createThumbnail(from photoData: Data, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        guard let uiImage = UIImage(data: photoData) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            uiImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func updateCapturability() {
        isCaptureAvailable = capturedPhotos.count < maxPhotosLimit
    }
    
    private func getNextContinuation() -> CheckedContinuation<CapturedPhoto, Error>? {
        guard !continuations.isEmpty else { return nil }
        return continuations.removeFirst()
    }
}
