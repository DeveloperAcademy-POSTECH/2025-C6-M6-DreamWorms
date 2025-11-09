//
//  VisionAnalysisError.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation

/// Vision 분석 중 발생하는 에러
enum VisionAnalysisError: LocalizedError {
    case imageProcessingFailed(String)
    case textRecognitionFailed(String)
    case documentDetectionFailed(String)
    case invalidImageData
    case noTablesFound
    case noTextFound
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed(let reason):
            return "이미지 처리 실패: \(reason)"
        case .textRecognitionFailed(let reason):
            return "텍스트 인식 실패: \(reason)"
        case .documentDetectionFailed(let reason):
            return "문서 감지 실패: \(reason)"
        case .invalidImageData:
            return "유효하지 않은 이미지 데이터"
        case .noTablesFound:
            return "감지된 테이블이 없습니다"
        case .noTextFound:
            return "감지된 텍스트가 없습니다"
        }
    }
}
