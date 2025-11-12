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
    @State private var selectedHour: Int? = nil
    
    let chart: CellChartData

    private let tickHours = Array(stride(from: 0, through: 21, by: 3))
    private let weekStyleScale: KeyValuePairs<String, Color> = [
        "1주차": .primaryNormal,
        "2주차": .primaryLight1,
        "3주차": .primaryStrong,
        "4주차": .primaryLight2,
    ]

    private var series: [HourlyVisit] {
        chart.seriesByWeekday[selectionWeekday] ?? []
    }

    private var summary: String {
        chart.summaryByWeekday[selectionWeekday] ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            CellChartTitle(address: chart.address, summary: summary)
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
                weekStyleScale: weekStyleScale,
                selectedHour: $selectedHour
            )
            .id(selectionWeekday)
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
