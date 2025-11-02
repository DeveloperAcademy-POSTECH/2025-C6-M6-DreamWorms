//
//  MainTabIdentifier.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

enum MainTabIdentifier: Hashable, CaseIterable {
    case map, dashboard, onePage
    
    var tabLabel: Label<Text, Image> {
        switch self {
        case .map:
            Label(
                String(localized: .map),
                systemImage: SymbolLiterals.map.rawValue
            )
        case .dashboard:
            Label(
                String(localized: .analyze),
                systemImage: SymbolLiterals.analytics.rawValue
            )
        case .onePage:
            Label(
                String(localized: .summary),
                systemImage: SymbolLiterals.people.rawValue
            )
        }
    }
}
