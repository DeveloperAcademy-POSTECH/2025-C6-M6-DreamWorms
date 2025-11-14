//
//  HourlyVisit.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Foundation

struct HourlyVisit: Identifiable, Hashable {
    let weekIndex: Int
    let weekday: Weekday
    let hour: Int
    let count: Int
    
    /// 같은 주차(weekIndex), 같은 요일(weekday), 같은 시간(hour) 조합은 동일한 데이터로 취급하기 위한 id 값
    /// Swift Chart ForEach에서 반복 렌더링하기 위함.
    var id: String { "\(weekIndex)-\(weekday.rawValue)-\(hour)" }
}
