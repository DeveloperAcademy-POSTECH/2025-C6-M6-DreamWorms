//
//  NaverMapOverlayOptions.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation
import UIKit

public struct NaverMapOverlayOptions {
    public var showCircleOverlay: Bool
    public var radiusStyle: RadiusStyle
    public var radiusPresets: Set<RadiusPreset>
    public var showFlowPath: Bool
    
    public init(
        showCircleOverlay: Bool = false,
        radiusStyle: RadiusStyle = .gradient,
        radiusPresets: Set<RadiusPreset> = [.small],
        showFlowPath: Bool = false
    ) {
        self.showCircleOverlay = showCircleOverlay
        self.radiusStyle = radiusStyle
        self.radiusPresets = radiusPresets
        self.showFlowPath = showFlowPath
    }
}

public enum RadiusPreset: Double, CaseIterable, Identifiable {
    case small = 500
    case medium = 1000
    case large = 1500
    
    public var id: Double { rawValue }
    
    var meters: Double { rawValue }
    
    var displayName: String {
        switch self {
        case .small:
            "500m"
        case .medium:
            "1km"
        case .large:
            "1.5km"
        }
    }
    
    var color: UIColor {
        switch self {
        case .small:
            .mainBlue
        case .medium:
            .mainBlue
        case .large:
            .mainBlue
        }
    }
    
    var fillAlpha: Double {
        switch self {
        case .small:
            0.25
        case .medium:
            0.15
        case .large:
            0.10
        }
    }
    
    var strokeAlpha: Double {
        switch self {
        case .small:
            0.6
        case .medium:
            0.5
        case .large:
            0.4
        }
    }
}

public enum RadiusStyle: String, Codable, Sendable {
    case gradient
    case stroke
}
