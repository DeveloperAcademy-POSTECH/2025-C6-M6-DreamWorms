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
    
    var description: String {
        switch self {
        case .home: "주민등록상 거주지, 실거주지 등 주요 은신처"
        case .work: "고용보험 취업정보, 실직장 등 주요 수입처"
        case .custom: "통화내역/주류내역/숙박내역 등 주요 소비처"
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
