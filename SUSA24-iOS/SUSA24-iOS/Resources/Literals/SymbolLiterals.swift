//
//  SymbolLiterals.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

enum SymbolLiterals: String {
    case map = "map"
    case analytics = "chart.pie"
    case people = "person.text.rectangle.fill"
    case setting = "gearshape"
    case person = "person.fill"
    case plus = "plus"
}

extension Image {
    init(_ symbol: SymbolLiterals) {
        self.init(systemName: symbol.rawValue)
    }
}
