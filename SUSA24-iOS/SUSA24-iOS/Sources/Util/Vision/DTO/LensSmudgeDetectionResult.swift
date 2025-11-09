//
//  LensSmudgeDetectionResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation

/// 렌즈 얼룩 감지 결과
/// TODO: 임시로 적용해둠
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
            return "렌즈 얼룩 감지"
        } else if confidence > 0.4 {
            return "렌즈 얼룩 약간 감지"
        } else {
            return "렌즈 깨끗함"
        }
    }
    
    /// 렌즈 상태 아이콘 색상
    var statusColor: String {
        if confidence > 0.7 {
            return "🔴"  // 빨강 (심각)
        } else if confidence > 0.4 {
            return "🟡"  // 노랑 (경고)
        } else {
            return "🟢"  // 초록 (정상)
        }
    }
}
