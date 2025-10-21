//  DateGroupStaySection.swift

import SwiftUI

/// 날짜별 체류 그룹 섹션
///
/// 역할: 날짜 헤더 + 체류 타임라인 조합
struct DateGroupStaySection: View {
    let date: Date
    let stays: [LocationStay]
    
    var body: some View {
        SectionContainer(
            date: date,
            stays: sortedStays
        )
    }
    
    /// 시간 역순 정렬 (최신이 위로)
    private var sortedStays: [LocationStay] {
        stays.sorted { $0.startTime > $1.startTime }
    }
}

// MARK: - Section Container

private struct SectionContainer: View {
    let date: Date
    let stays: [LocationStay]
    
    var body: some View {
        VStack(spacing: 16) {
            DateGroupHeader(date: date)
            StayTimelineList(stays: stays)
        }
    }
}

// MARK: - Preview

#Preview {
    DateGroupStaySection(
        date: Date(),
        stays: []
    )
    .padding()
}
