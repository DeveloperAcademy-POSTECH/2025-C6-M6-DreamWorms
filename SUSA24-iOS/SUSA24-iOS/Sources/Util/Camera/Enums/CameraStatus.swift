//
//  CameraStatus.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

// MARK: - Camera Status

/// 카메라 권한 + 상태

enum CameraStatus {
    case notInitialized
    case checking
    case unauthorized
    case running
    case failed
    case stopped
    
    var description: String {
        switch self {
        case .notInitialized:
            "초기화되지 않음"
        case .checking:
            "권한 확인 중"
        case .unauthorized:
            "권한 없음"
        case .running:
            "실행 중"
        case .failed:
            "실패"
        case .stopped:
            "중지됨"
        }
    }
}
