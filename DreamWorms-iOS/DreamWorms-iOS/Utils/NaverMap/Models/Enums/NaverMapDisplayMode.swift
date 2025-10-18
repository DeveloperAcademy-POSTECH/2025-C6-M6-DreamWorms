//
//  NaverMapDisplayMode.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation

public enum NaverMapDisplayMode: String, CaseIterable, Sendable {
    case uniqueLocations = "unique"       // 기본
    case frequency = "frequency"          // 빈도 표시
    case timeSequence = "sequence"        // 시간순 그룹화
    case flow = "flow"                    // 화살표 흐름 표시
    
    public var title: String {
        switch self {
        case .uniqueLocations:
            return "기본 위치"
        case .frequency:
            return "빈도 표시"
        case .timeSequence:
            return "시간순 그룹"
        case .flow:
            return "이동 경로"
        }
    }
}

public struct NaverMapOverlayOptions: Sendable {
    public var showCircleOverlay: Bool
    public var circleRadius: Double
    public var radiusStyle: RadiusStyle
    public var showFlowPath: Bool
    
    public init(
        showCircleOverlay: Bool = false,
        circleRadius: Double = 750.0,
        radiusStyle: RadiusStyle = .gradient,
        showFlowPath: Bool = false
    ) {
        self.showCircleOverlay = showCircleOverlay
        self.circleRadius = circleRadius
        self.radiusStyle = radiusStyle
        self.showFlowPath = showFlowPath
    }
}

public enum RadiusStyle: String, Codable, Sendable {
    case gradient
    case stroke
}
