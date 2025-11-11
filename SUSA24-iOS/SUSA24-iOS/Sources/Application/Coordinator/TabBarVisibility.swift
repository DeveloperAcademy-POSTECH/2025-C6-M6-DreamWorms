//
//  TabBarVisibility.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/11/25.
//

import SwiftUI

// SwiftUI의 Environment를 통해 앱 전체에서 TabBar의 표시/숨김 상태를 관리
@MainActor
@Observable
final class TabBarVisibility {
    
    /// TabBar의 현재 상태
    var isVisible: Bool = true
    
    func show() {
        isVisible = true
    }

    func hide() {
        isVisible = false
    }
    
    /// TabBar 를 보여줄 것인가.
    /// - Parameter visible: 표시 여부
    func setVisibility(_ visible: Bool) {
        isVisible = visible
    }
}
