//
//  SymbolLiterals.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

enum SymbolLiterals: String {
    case map = "map.fill"
    case analytics = "chart.bar.fill"
    case people = "person.text.rectangle.fill"
    case setting = "gearshape"
    case person = "person.fill"
    case plus
    case edit = "pencil"
    case share = "square.and.arrow.up"
    case delete = "trash"
    case xmark
    case xmarkFill = "xmark.circle.fill"
    case warningCircle = "exclamationmark.circle.fill"
    case camera = "camera.fill"
    case back = "chevron.left"
    case search = "magnifyingglass"
    case scan = "document.viewfinder"
    case myPosition = "paperplane"
    case mapLayerDefault = "square.2.layers.3d"
    case mapLayerFill = "square.2.layers.3d.fill"
    case checkmark
    case checkmarkFill = "checkmark.square.fill"
    case rightArrow = "chevron.right"
    case pin
    case pinFill = "pin.fill"
    case ellipsis
    case radioSelected = "button.programmable"
    case radioDeselected = "circle"
    case expand = "arrow.up.left.and.arrow.down.right"
    case minus
    case tracking = "point.3.filled.connected.trianglepath.dotted"
}

extension Image {
    init(_ symbol: SymbolLiterals) {
        self.init(systemName: symbol.rawValue)
    }
}
