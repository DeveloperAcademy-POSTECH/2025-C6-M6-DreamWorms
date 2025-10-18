//
//  View+ScreenSize.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI

extension View {
    /// 디바이스의 스크린 너비 값
    var screenWidth: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .screen
            .bounds.width) ?? 0
    }

    /// 디바이스의 스크린 높이 값
    var screenHeight: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .screen
            .bounds.height) ?? 0
    }
}
