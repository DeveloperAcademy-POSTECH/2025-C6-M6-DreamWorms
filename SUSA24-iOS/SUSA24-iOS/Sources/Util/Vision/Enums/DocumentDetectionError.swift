//
//  DocumentDetectionError.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation

/// 실시간 문서 감지 중 발생하는 에러
enum DocumentDetectionError: LocalizedError {
    case processorNotInitialized
    case frameStreamUnavailable
    case visionProcessingFailed(String)
    case documentNotDetected
    case lensSmudgeCheckFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .processorNotInitialized:
            return "Vision 프로세서가 초기화되지 않았습니다"
        case .frameStreamUnavailable:
            return "카메라 프레임 스트림을 사용할 수 없습니다"
        case .visionProcessingFailed(let reason):
            return "Vision 처리 실패: \(reason)"
        case .documentNotDetected:
            return "감지된 문서가 없습니다"
        case .lensSmudgeCheckFailed(let reason):
            return "렌즈 얼룩 감지 실패: \(reason)"
        }
    }
}
