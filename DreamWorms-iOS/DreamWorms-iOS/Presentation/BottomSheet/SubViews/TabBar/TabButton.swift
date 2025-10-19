//
//  TabButton.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 개별 탭 버튼
///
/// 역할: 버튼 액션만
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            TabText(title: title, isSelected: isSelected)
        }
    }
}

// MARK: - Preview

#Preview {
    HStack {
        TabButton(title: "기지국", isSelected: true, action: {})
        TabButton(title: "카드내역", isSelected: false, action: {})
    }
}
