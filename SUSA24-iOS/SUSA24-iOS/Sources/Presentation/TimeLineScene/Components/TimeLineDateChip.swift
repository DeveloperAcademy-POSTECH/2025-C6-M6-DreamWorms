//
//  TimeLineDateChip.swift
//  SUSA24-iOS
//
//  Created by mini on 11/6/25.
//

import SwiftUI

// MARK: - View

/// 타임라인 날짜 칩 (DWTappedPin 활용)
///
/// DWTappedPin을 활용한 간단한 날짜 칩입니다.
/// 탭하면 해당 날짜 섹션으로 스크롤됩니다.
struct TimeLineDateChip: View {
    let date: Date
    let onTap: (Date) -> Void
    
    var body: some View {
        DWTappedPin(
            text: date.formatted("M.d"),  // Date Extension 활용
            action: { onTap(date) }
        )
        .colors(
            normal: (bg: .mainBackground, text: .labelNeutral, border: .labelCoolNormal),
            tapped: (bg: .mainAlternative, text: .labelAlternative, border: .clear)
        )
    }
}

// MARK: - Date Chip List View

/// 날짜 칩 리스트 뷰
struct TimeLineDateChipList: View {
    let dates: [Date]
    let onDateTapped: (Date) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(dates, id: \.self) { date in
                    TimeLineDateChip(
                        date: date,
                        onTap: onDateTapped
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview

//#Preview("Date Chip List") {
//    let dates = [
//        Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 30))!,
//        Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 29))!,
//        Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 28))!,
//        Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 27))!,
//        Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 26))!,
//    ]
//    
//    TimeLineDateChipList(
//        dates: dates,
//        onDateTapped: { date in
//            print("Selected: \(date)")
//        }
//    )
//    .padding()
//    .background(.mainBackground)
//}
