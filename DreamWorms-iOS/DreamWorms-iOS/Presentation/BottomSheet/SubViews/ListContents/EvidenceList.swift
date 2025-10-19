//
//  EvidenceList.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 증거 리스트
///
/// 역할: 날짜별 그룹 나열만
struct EvidenceList: View {
    let evidences: [Evidence]
    
    var body: some View {
        ListScrollView(evidences: evidences)
    }
}

// MARK: - List ScrollView

/// 리스트 스크롤뷰
///
/// 역할: 스크롤 컨테이너만
private struct ListScrollView: View {
    let evidences: [Evidence]
    
    var body: some View {
        ScrollView {
            ListContent(evidences: evidences)
        }
    }
}

// MARK: - List Content

/// 리스트 컨텐츠
///
/// 역할: 날짜별 그룹 나열만
private struct ListContent: View {
    let evidences: [Evidence]
    
    var body: some View {
        LazyVStack(spacing: 24, pinnedViews: []) {
            ForEach(groupedByDate, id: \.key) { date, items in
                DateGroupSection(
                    date: date,
                    items: items
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    /// 날짜별 그룹핑 (최신순)
    private var groupedByDate: [(key: Date, value: [Evidence])] {
        let grouped = Dictionary(grouping: evidences) { evidence in
            Calendar.current.startOfDay(for: evidence.recordedAt)
        }
        
        return grouped.sorted { $0.key > $1.key } // ✅ 최신 날짜가 위로
    }
}

// MARK: - Preview

#Preview {
    EvidenceList(evidences: Evidence.mockData)
}
