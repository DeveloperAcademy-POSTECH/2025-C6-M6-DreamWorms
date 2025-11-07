//
//  SymbolLiterals.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

enum SymbolLiterals: String {
    case map = "map.fill"
    case analytics = "chart.pie.fill"
    case people = "person.text.rectangle.fill"
    case setting = "gearshape"
    case person = "person.fill"
    case plus
    case edit = "pencil"
    case share = "square.and.arrow.up"
    case delete = "trash"
    case xmark
    case warningCircle = "exclamationmark.circle.fill"
    case camera = "camera.fill"
    case back = "chevron.left"
    case search = "magnifyingglass"
    case scan = "document.viewfinder"
    case myPosition = "paperplane"
    case mapLayerDefault = "square.2.layers.3d"
    case mapLayerFill = "square.2.layers.3d.fill"
    case checkmark
    case rightArrow = "chevron.right"
}

extension Image {
    init(_ symbol: SymbolLiterals) {
        self.init(systemName: symbol.rawValue)
    }
}
