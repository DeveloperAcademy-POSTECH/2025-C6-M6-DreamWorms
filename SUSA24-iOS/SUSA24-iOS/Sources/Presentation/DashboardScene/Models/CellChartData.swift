//
//  CellChartData.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Foundation

struct CellChartData: Identifiable, Equatable, Sendable {
    let id = UUID()
    let address: String
    var selectedWeekday: Weekday
    var summary: String
    var series: [HourlyVisit]
}
