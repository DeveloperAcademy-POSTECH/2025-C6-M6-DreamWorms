//
//  DocumentDetectionResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import CoreGraphics
import Foundation

/// 문서 감지 결과
struct DocumentDetectionResult: Sendable {
    /// 감지된 문서의 경계 (정규화 좌표: 0~1, 좌하단 원점)
    let boundingBox: CGRect
    
    /// 문서의 4개 꼭짓점 (정규화 좌표)
    /// 순서: 좌상, 우상, 우하, 좌하
    let corners: [CGPoint]
    
    /// 감지 신뢰도 (0.0 ~ 1.0)
    let confidence: Float
    
    /// 분석된 프레임의 타임스탐프
    let timestamp: TimeInterval
    
    /// 유효한 감지 여부 (신뢰도 >= 0.5)
    var isValid: Bool {
        confidence >= 0.5
    }
    
    /// 화면 크기에 맞춰 좌표를 변환합니다
    /// - Parameter screenSize: 화면 크기
    /// - Returns: 화면 좌표로 변환된 정규화 좌표들
    func toScreenCoordinates(screenSize: CGSize) -> [CGPoint] {
        corners.map { point in
            CGPoint(
                x: point.x * screenSize.width,
                y: (1.0 - point.y) * screenSize.height  // Vision: 좌하단 → 좌상단
            )
        }
    }
}
