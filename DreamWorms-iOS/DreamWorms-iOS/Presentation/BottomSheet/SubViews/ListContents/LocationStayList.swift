//  LocationStayList.swift

import SwiftUI

/// 위치 체류 리스트
///
/// 역할: 날짜별 그룹 나열
struct LocationStayList: View {
    let locationStays: [LocationStay]
    
    var body: some View {
        if locationStays.isEmpty {
            EmptyStateView()
        } else {
            ListScrollView(locationStays: locationStays)
        }
    }
}

// MARK: - Empty State

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "map.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.grayD9)
            
            Text("위치 데이터가 없습니다")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.gray8B)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - List ScrollView

private struct ListScrollView: View {
    let locationStays: [LocationStay]
    
    var body: some View {
        ScrollView {
            ListContent(locationStays: locationStays)
        }
    }
}

// MARK: - List Content

private struct ListContent: View {
    let locationStays: [LocationStay]
    
    var body: some View {
        LazyVStack(spacing: 24, pinnedViews: []) {
            ForEach(groupedByDate, id: \.key) { date, stays in
                DateGroupStaySection(
                    date: date,
                    stays: stays
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    /// 날짜별 그룹핑 (최신순)
    private var groupedByDate: [(key: Date, value: [LocationStay])] {
        let grouped = Dictionary(grouping: locationStays) { stay in
            Calendar.current.startOfDay(for: stay.startTime)
        }
        
        return grouped.sorted { $0.key > $1.key } // 최신 날짜가 위로
    }
}

// MARK: - Preview

#Preview {
    LocationStayList(locationStays: [])
}
