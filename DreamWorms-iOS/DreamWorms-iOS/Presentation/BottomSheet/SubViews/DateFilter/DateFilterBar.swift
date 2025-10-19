//
//  DateFilterBar.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 날짜 필터 바
///
/// 역할: 날짜 입력 + 캘린더 버튼 조합만
struct DateFilterBar: View {
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    
    var body: some View {
        FilterContainer(
            startDate: $startDate,
            endDate: $endDate
        )
    }
}

// MARK: - Filter Container

/// 필터 컨테이너
///
/// 역할: 레이아웃 + 패딩만
private struct FilterContainer: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    
    var body: some View {
        HStack(spacing: 0) {
            DateRangeInput(
                startDate: $startDate,
                endDate: $endDate
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.grayFB))
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

#Preview("Empty") {
    DateFilterBar()
}

#Preview("With Dates") {
    DateFilterBar()
}
