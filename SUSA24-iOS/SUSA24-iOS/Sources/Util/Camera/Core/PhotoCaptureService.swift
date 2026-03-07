//
//  PhotoCaptureService.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import AVFoundation
import UIKit

// MARK: - Delegate Conformance

extension PhotoCaptureService: AVCapturePhotoCaptureDelegate {}

/// 사진 촬영 및 관리를 담당
@Observable
final class PhotoCaptureService: NSObject {
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchSerialQueue(label: "com.dreamworms.susa24.camera.sessionQueue")
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }
    
    private(set) var capturedPhotos: [CapturedPhoto] = []
    private(set) var lastThumbnail: UIImage?
    private(set) var isCaptureAvailable: Bool = true
    
    private let maxPhotosLimit = 10
    private var continuations: [CheckedContinuation<CapturedPhoto, Error>] = []
    
    /// 사진 촬영 출력 객체를 반환
    var output: AVCapturePhotoOutput {
        photoOutput
    }
    
    /// 사진을 촬영
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
    
    /// 마지막으로 촬영된 사진의 섬네일을 반환
    func getLastThumbnail() -> UIImage? {
        lastThumbnail
    }
    
    /// 촬영된 모든 사진을 반환
    func getAllPhotos() -> [CapturedPhoto] {
        capturedPhotos
    }
    
    /// 특정 인덱스의 사진을 삭제
    func deletePhoto(at index: Int) {
        guard index >= 0, index < capturedPhotos.count else { return }
        capturedPhotos.remove(at: index)
        updateCapturability()
    }
    
    /// 모든 사진을 삭제
    func clearAllPhotos() {
        capturedPhotos.removeAll()
        lastThumbnail = nil
        updateCapturability()
    }
    
    // MARK: - Internal Methods (델리게이트 파일에서 사용)
    
    func addCapturedPhoto(_ photoData: Data) async {
        guard capturedPhotos.count < maxPhotosLimit else {
            let continuation = getNextContinuation()
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
        
        let continuation = getNextContinuation()
        continuation?.resume(returning: capturedPhoto)
    }
    
    func resumeWithError(_ error: Error) async {
        let continuation = getNextContinuation()
        continuation?.resume(throwing: error)
    }
    
    // MARK: - Private Methods
    
    private func createThumbnail(
        from photoData: Data,
        size: CGSize = CGSize(width: 100, height: 100)
    ) -> UIImage? {
        guard let uiImage = UIImage(data: photoData) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            uiImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func updateCapturability() {
        isCaptureAvailable = capturedPhotos.count < maxPhotosLimit
    }
    
    func getNextContinuation() -> CheckedContinuation<CapturedPhoto, Error>? {
        guard !continuations.isEmpty else { return nil }
        return continuations.removeFirst()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension PhotoCaptureService {
    /// 사진 촬영 완료 후 호출되는 메서드
    /// - Parameters:
    ///   - output: 사진 촬영을 수행한 AVCapturePhotoOutput
    ///   - photo: 촬영된 사진 데이터
    ///   - error: 촬영 중 발생한 에러 (성공시 nil)
    nonisolated func photoOutput(
        _: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        // 에러 처리
        if let error {
            Task {
                await self.resumeWithError(error)
            }
            return
        }
        
        // 사진 데이터 추출
        guard let photoData = photo.fileDataRepresentation() else {
            Task {
                await self.resumeWithError(PhotoCaptureError.noPhotoData)
            }
            return
        }
        
        // 사진 저장 및 처리
        Task {
            await self.addCapturedPhoto(photoData)
        }
    }
}
