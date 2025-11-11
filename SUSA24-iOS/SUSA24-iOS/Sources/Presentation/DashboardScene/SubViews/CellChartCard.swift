//
//  CellChartCard.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Charts
import SwiftUI

struct CellChartCard: View {
    @Binding var selectionWeekday: Weekday
    var address: String = ""
    var summary: String = ""
    let series: [HourlyVisit]
    
    private let tickHours = Array(stride(from: 0, through: 21, by: 3))
    private let weekStyleScale: KeyValuePairs<String, Color> = [
        "1주차": .primaryNormal,
        "2주차": .primaryLight1,
        "3주차": .primaryStrong,
        "4주차": .primaryLight2,
    ]
    private var availableWeeks: [Int] {
        let set = Set(series.map(\.weekIndex))
        return set.sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CellChartTitle(address: address, summary: summary)
                .padding(.bottom, 32)
            
            CellChartLegend(
                series: series,
                weekStyleScale: weekStyleScale
            )
            .padding(.bottom, series.isEmpty ? 0 : 16)
            .opacity(series.isEmpty ? 0 : 1)
            
            CellChartGraph(
                series: series,
                tickHours: tickHours,
                weekStyleScale: weekStyleScale
            )
            .frame(height: 142)
            .padding(.bottom, 18)
            
            WeekdayPillPicker(selection: $selectionWeekday)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.mainBackground)
        .cornerRadius(12)
        .shadow(
            color: .black.opacity(0.05),
            radius: 12,
            x: 0,
            y: 2
        )
    }
}

//#Preview {
//    @Previewable @State var selectionWeekday: Weekday = .mon
//    ZStack {
//        Color.mainAlternative.ignoresSafeArea()
//        
//        VStack(spacing: 12) {
//            CellChartCard(selectionWeekday: $selectionWeekday, address: "퇴계로20길 56", summary: "오전 7-8시에 주로 머물렀습니다.", series: [
//            ])
//            
//            CellChartCard(selectionWeekday: $selectionWeekday, series: [
//            ])
//        }
//        .padding(.horizontal, 16)
//    }
//}
