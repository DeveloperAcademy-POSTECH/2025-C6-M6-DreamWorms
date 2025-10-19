//
//  EvidenceTabBar.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 증거 타입 탭바
///
/// 역할: 상태 관리만
struct EvidenceTabBar: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabBarContainer(selectedTab: $selectedTab)
    }
}

// MARK: - TabBar Container

/// 탭바 컨테이너
///
/// 역할: 구조 조합만
private struct TabBarContainer: View {
    @Binding var selectedTab: Int
    
    private let tabs = ["기지국", "카드내역", "차량정보", "범행장소"]
    
    var body: some View {
        VStack(spacing: 10) {
            TabContent(
                tabs: tabs,
                selectedTab: $selectedTab
            )
        }
    }
}

// MARK: - Tab Content

/// 탭 컨텐츠
///
/// 역할: 탭 + 인디케이터 조합만
private struct TabContent: View {
    let tabs: [String]
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            TabButtonsRow(
                tabs: tabs,
                selectedTab: $selectedTab
            )
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        EvidenceTabBar()
        Text("컨텐츠 영역")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
