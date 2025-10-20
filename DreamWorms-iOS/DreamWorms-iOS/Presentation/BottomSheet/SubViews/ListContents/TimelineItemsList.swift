//
//  TimelineItemsList.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 타임라인 아이템 리스트
///
/// 역할: 아이템 나열만
struct TimelineItemsList: View {
    let items: [Evidence]
    
    var body: some View {
        ItemsStack(items: items)
    }
}

// MARK: - Items Stack

/// 아이템 스택
///
/// 역할: 아이템 나열만
private struct ItemsStack: View {
    let items: [Evidence]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                TimelineItem(
                    evidence: item,
                    isLast: index == items.count - 1 // ✅ 마지막 여부
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TimelineItemsList(items: Evidence.mockData)
        .padding()
}
