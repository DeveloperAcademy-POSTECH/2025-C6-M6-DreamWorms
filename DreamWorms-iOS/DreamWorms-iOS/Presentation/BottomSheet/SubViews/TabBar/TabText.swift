//
//  TabText.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 탭 텍스트
///
/// 역할: 텍스트 스타일만
struct TabText: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.pretendardSemiBold(size: 15))
            .foregroundStyle(textColor)
    }
    
    private var textColor: Color {
        isSelected ? Color.mainBlue : Color.gray8B
    }
}

// MARK: - Preview

#Preview {
    VStack {
        TabText(title: "기지국", isSelected: true)
        TabText(title: "카드내역", isSelected: false)
    }
}
