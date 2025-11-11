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
    
    /// 현재 선택된 요일
    var selectedWeekday: Weekday

    /// 모든 주차 × 모든 요일 × 시간대 데이터
    let allSeries: [HourlyVisit]

    /// 현재 선택된 요일에 대한 시리즈 (View에서 사용)
    var series: [HourlyVisit]

    /// 현재 선택된 요일 기준 summary
    var summary: String
}
