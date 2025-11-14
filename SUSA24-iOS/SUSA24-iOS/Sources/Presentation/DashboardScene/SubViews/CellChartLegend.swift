//
//  CellChartLegend.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import SwiftUI

struct CellChartLegend: View {
    let series: [HourlyVisit]
    let weekStyleScale: KeyValuePairs<String, Color>
    
    private var availableWeeks: [Int] {
        let set = Set(series.map(\.weekIndex))
        return set.sorted()
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 10) {
                ForEach(availableWeeks, id: \.self) { week in
                    HStack(spacing: 6) {
                        Capsule()
                            .fill(weekStyleScale.first(where: { $0.key == "\(week)주차" })?.value ?? .labelAssistive)
                            .frame(width: 10, height: 3)
                        Text(.chartLegendWeek(number: week))
                            .font(.bodyMedium10)
                            .foregroundStyle(.labelNormal)
                    }
                }
            }
        }
    }
}
