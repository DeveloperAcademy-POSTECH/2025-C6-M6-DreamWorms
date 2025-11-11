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
    
    private var availableWeeks: [Int] {
        Array(Set(series.map(\.weekIndex))).sorted()
    }
    
    var body: some View {
        Chart {
            ForEach(availableWeeks, id: \.self) { week in
                let weekData = series
                    .filter { $0.weekIndex == week }
                    .sorted { $0.hour < $1.hour }

                ForEach(weekData) { item in
                    LineMark(
                        x: .value("Hour", item.hour),
                        y: .value("Visits", item.count),
                        series: .value("주차", "\(week)주차")
                    )
                }
                .interpolationMethod(.catmullRom)
                .foregroundStyle(by: .value("주차", "\(week)주차"))
            }
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
    }
}
