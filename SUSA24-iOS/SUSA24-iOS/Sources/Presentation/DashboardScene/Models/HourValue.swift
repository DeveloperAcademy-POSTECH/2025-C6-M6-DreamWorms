//
//  HourValue.swift
//  SUSA24-iOS
//
//  Created by mini on 11/4/25.
//

import Foundation

struct HourValue: Identifiable, Hashable, Sendable {
    let hour: Int
    let value: Double
    var id: Int { hour }
}

enum WeekSlice: Sendable { case lastWeek, thisWeek }

struct LocationRank: Identifiable, Sendable {
    let id = UUID()
    let address: String
    let count: Int
}
