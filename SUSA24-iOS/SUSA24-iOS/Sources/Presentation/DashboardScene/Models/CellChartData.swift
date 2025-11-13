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

    let seriesByWeekday: [Weekday: [HourlyVisit]]
    let summaryByWeekday: [Weekday: String]

    var selectedWeekday: Weekday

    init(address: String, allSeries: [HourlyVisit], initialWeekday: Weekday) {
        self.address = address
        self.allSeries = allSeries
        self.selectedWeekday = initialWeekday

        var seriesDict: [Weekday: [HourlyVisit]] = [:]
        var summaryDict: [Weekday: String] = [:]

        for weekday in Weekday.allCases {
            let filtered = allSeries.filter { $0.weekday == weekday }
            seriesDict[weekday] = filtered
            summaryDict[weekday] = filtered.makeHourlySummary()
        }

        self.seriesByWeekday = seriesDict
        self.summaryByWeekday = summaryDict
    }
}
