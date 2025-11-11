//
//  WeekDay.swift
//  SUSA24-iOS
//
//  Created by mini on 11/4/25.
//

import SwiftUI

enum Weekday: Int, CaseIterable, Identifiable {
    case mon, tue, wed, thu, fri, sat, sun
    var id: Int { rawValue }
    
    init?(systemWeekday: Int) {
        switch systemWeekday {
        case 2: self = .mon
        case 3: self = .tue
        case 4: self = .wed
        case 5: self = .thu
        case 6: self = .fri
        case 7: self = .sat
        case 1: self = .sun
        default: return nil
        }
    }
    
    var shortKR: String {
        switch self {
        case .mon: "월"
        case .tue: "화"
        case .wed: "수"
        case .thu: "목"
        case .fri: "금"
        case .sat: "토"
        case .sun: "일"
        }
    }
}
