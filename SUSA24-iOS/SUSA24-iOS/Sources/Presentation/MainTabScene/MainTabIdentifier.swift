//
//  MainTabIdentifier.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

enum MainTabIdentifier: Hashable, CaseIterable {
    case map, dashboard, onePage
    
    var title: String {
        switch self {
        case .map: String(localized: .map)
        case .dashboard: String(localized: .analyze)
        case .onePage: String(localized: .summary)
        }
    }
    
    var icon: Image {
        switch self {
        case .map: Image(.map)
        case .dashboard: Image(.analytics)
        case .onePage: Image(.people)
        }
    }
}
