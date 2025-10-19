//
//  TimelineItem.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 타임라인 아이템
///
/// 역할: 세로선 + 점 + 컨텐츠 조합만
struct TimelineItem: View {
    let evidence: Evidence
    let isLast: Bool
    
    var body: some View {
        ItemRow(
            evidence: evidence,
            isLast: isLast
        )
    }
}

// MARK: - Item Row

/// 아이템 행
///
/// 역할: 타임라인 + 컨텐츠 조합만
private struct ItemRow: View {
    let evidence: Evidence
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VerticalTimeline(isLast: isLast)
            
            TimelineContent(
                location: evidence.displayName,
                startTime: evidence.recordedAt,
                endTime: evidence.recordedAt.addingTimeInterval(3600)
            )
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        TimelineItem(
            evidence: Evidence.mockData[0],
            isLast: false
        )
        
        TimelineItem(
            evidence: Evidence.mockData[1],
            isLast: false
        )
        
        TimelineItem(
            evidence: Evidence.mockData[2],
            isLast: true // ✅ 마지막
        )
    }
    .padding()
}
