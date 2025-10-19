//
//  TabButtonRow.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 탭 버튼 행
///
/// 역할: 탭 나열 + 선택 액션만
struct TabButtonsRow: View {
    let tabs: [String]
    @Binding var selectedTab: Int
    
    var body: some View {
        ButtonsContainer(
            tabs: tabs,
            selectedTab: $selectedTab
        )
    }
}

// MARK: - Buttons Container

/// 버튼 컨테이너
///
/// 역할: 레이아웃 + 패딩만
private struct ButtonsContainer: View {
    let tabs: [String]
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 18) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, title in
                TabButton(
                    title: title,
                    isSelected: selectedTab == index,
                    action: { selectTab(index) }
                )
            }
            Spacer()
        }
        .padding(.horizontal, 18)
    }
    
    private func selectTab(_ index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTab = index
        }
    }
}

// MARK: - Preview

#Preview {
    TabButtonsRow(
        tabs: ["기지국", "카드내역", "차량정보", "범행장소"],
        selectedTab: .constant(0)
    )
}
