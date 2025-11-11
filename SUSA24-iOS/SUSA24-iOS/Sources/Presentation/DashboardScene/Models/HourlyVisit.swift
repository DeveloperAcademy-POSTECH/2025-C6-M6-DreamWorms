//
//  HourlyVisit.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Foundation

struct HourlyVisit: Identifiable, Hashable {
    let id = UUID()
    let weekIndex: Int
    let weekday: Weekday
    let hour: Int
    let count: Int
}
