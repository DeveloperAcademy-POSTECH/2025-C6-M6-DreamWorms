//
//  CoverageRangeType.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/9/25.
//

import SwiftUI

/// 지도 레이어 설정 시 사용되는 커버리지 반경 옵션입니다.
/// 단위: Km
enum CoverageRangeType: CaseIterable, Identifiable {
    case half
    case one
    case two
    case three
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .half: ".5 km"
        case .one: "1 km"
        case .two: "2 km"
        case .three: "3 km"
        }
    }
    
    var imageResource: ImageResource {
        switch self {
        case .half: .coverageHarfKm
        case .one: .coverage1Km
        case .two: .coverage2Km
        case .three: .coverage3Km
        }
    }
}
