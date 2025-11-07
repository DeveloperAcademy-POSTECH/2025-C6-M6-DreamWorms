//
//  PhotoCaptureError.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import Foundation

// MARK: - Error

/// 촬영 중 에러 상태

enum PhotoCaptureError: LocalizedError {
    case noPhotoData
    case captureFailure
    case maxPhotosExceeded
    
    var errorDescription: String? {
        switch self {
        case .noPhotoData:
            "사진 데이터를 받을 수 없습니다."
        case .captureFailure:
            "사진 촬영에 실패했습니다."
        case .maxPhotosExceeded:
            "최대 10장까지만 촬영할 수 있습니다."
        }
    }
}
