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
            return "초기화되지 않음"
        case .checking:
            return "권한 확인 중"
        case .unauthorized:
            return "권한 없음"
        case .running:
            return "실행 중"
        case .failed:
            return "실패"
        case .stopped:
            return "중지됨"
        }
    }
}
