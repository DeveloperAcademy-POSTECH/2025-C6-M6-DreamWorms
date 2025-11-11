//
//  LensSmudgeDetectionResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation

/// 렌즈 얼룩 감지 결과
struct LensSmudgeDetectionResult: Sendable {
    /// 렌즈 얼룩 신뢰도 (0.0 ~ 1.0, 높을수록 더 많이 얼룩됨)
    let confidence: Float
    
    /// 렌즈가 얼룩되었는지 여부 (신뢰도 > 0.5)
    let isSmudged: Bool
    
    /// 분석된 프레임의 타임스탐프
    let timestamp: TimeInterval
    
    /// 렌즈 상태를 문자열로 반환
    var statusText: String {
        if confidence > 0.7 {
            return "정확도를 위해 카메라 렌즈를 닦아주세요"
        } else {
            return ""
        }
    }
}
