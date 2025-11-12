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
        case let .imageProcessingFailed(reason):
            "이미지 처리 실패: \(reason)"
        case let .textRecognitionFailed(reason):
            "텍스트 인식 실패: \(reason)"
        case let .documentDetectionFailed(reason):
            "문서 감지 실패: \(reason)"
        case .invalidImageData:
            "유효하지 않은 이미지 데이터"
        case .noTablesFound:
            "감지된 테이블이 없습니다"
        case .noTextFound:
            "감지된 텍스트가 없습니다"
        }
    }
}
