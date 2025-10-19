//
//  HeaderDropdownButton.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

/// 헤더 드롭다운 버튼
///
/// 역할: 드롭다운 아이콘만
struct HeaderDropdownButton: View {
    var body: some View {
        Button {
            // TODO: 드롭다운 액션
        } label: {
            DropdownIcon()
        }
    }
}

// MARK: - Dropdown Icon

/// 드롭다운 아이콘
///
/// 역할: 아이콘 UI만
private struct DropdownIcon: View {
    var body: some View {
        Image("icn_leftArrow24")
            .rotationEffect(.degrees(270))
    }
}

// MARK: - Preview

#Preview {
    HeaderDropdownButton()
}
