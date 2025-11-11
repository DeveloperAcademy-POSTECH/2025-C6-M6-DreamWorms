//
//  ZoomState.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

/// 이미지 줌 및 드래그 상태 관리
struct ZoomState {
    var scale: CGFloat = 1.0
    var lastScale: CGFloat = 1.0
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var anchor: UnitPoint = .center
}
