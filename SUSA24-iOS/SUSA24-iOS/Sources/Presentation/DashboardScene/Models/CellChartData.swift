//
//  CellChartData.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Foundation

struct CellChartData: Identifiable, Equatable {
    let id = UUID()
    let address: String
    let allSeries: [HourlyVisit]
    let weekRanges: [Int: String]
    let initialWeekday: Weekday
    var selectedWeekday: Weekday
    
    var seriesByWeekday: [Weekday: [HourlyVisit]] {
        Dictionary(grouping: allSeries, by: \.weekday)
    }

    var summaryByWeekday: [Weekday: String] {
        Dictionary(
            uniqueKeysWithValues: Weekday.allCases.map { weekday in
                let series = seriesByWeekday[weekday] ?? []
                return (weekday, series.makeHourlySummary())
            }
        )
    }
}
