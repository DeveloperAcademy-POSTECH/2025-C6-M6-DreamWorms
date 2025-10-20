//
//  DateGroupSection.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 날짜별 그룹 섹션
///
/// 역할: 날짜 헤더 + 타임라인 리스트 조합만
struct DateGroupSection: View {
    let date: Date
    let items: [Evidence]
    
    var body: some View {
        SectionContainer(
            date: date,
            items: sortedItems
        )
    }
    
    /// 시간 역순 정렬 (최신이 위로)
    private var sortedItems: [Evidence] {
        items.sorted { $0.recordedAt > $1.recordedAt } // ✅ 최신 시간이 위로
    }
}

// MARK: - Section Container

/// 섹션 컨테이너
///
/// 역할: 헤더 + 리스트 조합만
private struct SectionContainer: View {
    let date: Date
    let items: [Evidence]
    
    var body: some View {
        VStack(spacing: 16) {
            DateGroupHeader(date: date)
            TimelineItemsList(items: items)
        }
    }
}

// MARK: - Preview

#Preview {
    DateGroupSection(
        date: Date(),
        items: Evidence.mockData
    )
    .padding()
}
