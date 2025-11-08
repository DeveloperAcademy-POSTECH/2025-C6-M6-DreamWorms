//
//  CellChartGraph.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Charts
import SwiftUI

struct CellChartGraph: View {
    let series: [HourlyVisit]
    let tickHours: [Int]
    let weekStyleScale: KeyValuePairs<String, Color>
    
    var body: some View {
        Chart(series) { item in
            LineMark(
                x: .value("Hour", item.hour),
                y: .value("Visits", item.count),
                series: .value("주차", item.weekLabel)
            )
            .foregroundStyle(by: .value("주차", item.weekLabel))
            .interpolationMethod(.catmullRom)
        }
        .chartLegend(.hidden)
        .chartForegroundStyleScale(weekStyleScale)
        .chartXAxis {
            AxisMarks(values: tickHours) { value in
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text(String(format: "%02d", v))
                            .font(.numberMedium12)
                            .foregroundStyle(.labelAssistive)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in AxisGridLine() }
        }
        .chartYScale(domain: 0 ... 11)
        .overlay {
            TimeLineEmptyState(message: .dashboardEmptyChartMessage)
                .setupFont(.bodyMedium12)
                .opacity(series.isEmpty ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.5), value: series)
    }
}
