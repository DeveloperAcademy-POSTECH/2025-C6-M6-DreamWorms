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
        case .work: "범행지"
        case .custom: "기타"
        }
    }
    
    var description: String {
        switch self {
        case .home: "주민등록주소/실거주지/은신처 등 생활거점"
        case .work: "전과기록/증거물/수사보고서 등 주요 범행기록"
        case .custom: "직장/단골가게/전화발신주소 등 주요 활동기록"
        }
    }

    var icon: Image {
        switch self {
        case .home: Image(.icnHome)
        case .work: Image(.icnCrime)
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
