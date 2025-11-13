//
//  PinCategoryType.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

enum PinCategoryType: Int16, Codable, CaseIterable {
    case custom = 3
    case home = 0
    case work = 1

    init(_ raw: Int16) {
        self = PinCategoryType(rawValue: raw) ?? .custom
    }

    var text: String {
        switch self {
        case .home: "거주지"
        case .work: "근무지"
        case .custom: "기타"
        }
    }

    var icon: Image {
        switch self {
        case .home: Image(.icnHome)
        case .work: Image(.icnWork)
        case .custom: Image(.icnPin)
        }
    }

    var iconSize: CGSize {
        switch self {
        case .home: CGSize(width: 16, height: 16)
        case .work: CGSize(width: 18, height: 18)
        case .custom: CGSize(width: 18, height: 16)
        }
    }

    var iconWidth: CGFloat { iconSize.width }
    var iconHeight: CGFloat { iconSize.height }
}
