//
//  MainTabIdentifier.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

enum MainTabIdentifier: Hashable, CaseIterable {
    case map, tracking, analyze
    
    var title: String {
        switch self {
        case .map: String(localized: .map)
        case .tracking: String(localized: .tracking)
        case .analyze: String(localized: .analyze)
        }
    }
    
    var icon: Image {
        switch self {
        case .map: Image(.map)
        case .tracking: Image(.tracking)
        case .analyze: Image(.analytics)
        }
    }
}
