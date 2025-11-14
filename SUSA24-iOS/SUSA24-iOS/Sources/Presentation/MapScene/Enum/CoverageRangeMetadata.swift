//
//  CoverageRangeMetadata.swift
//  SUSA24-iOS
//
//  Created by GPT-5 Codex on 11/13/25.
//

import Foundation

/// 커버리지 타입을 지도 렌더링에 필요한 값(캐시 키, 반경)으로 변환하는 메타데이터입니다.
enum CoverageRangeMetadata {
    static func cacheKey(for range: CoverageRangeType) -> String {
        switch range {
        case .half: "coverage_0.5km"
        case .one: "coverage_1km"
        case .two: "coverage_2km"
        case .three: "coverage_3km"
        }
    }
    
    static func radiusMeters(for range: CoverageRangeType) -> Double {
        switch range {
        case .half: 500
        case .one: 1000
        case .two: 2000
        case .three: 3000
        }
    }
}
