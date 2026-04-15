//
//  Date+Format.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import Foundation

// MARK: - Date Extension

extension Date {
    /// 월.일 포맷 (예: "4.15")
    var monthDay: String {
        formatted(.dateTime.month(.defaultDigits).day(.defaultDigits).locale(Locale(identifier: "en_US_POSIX")))
    }

    /// 시:분 포맷 (예: "13:44 PM")
    var hourMinute: String {
        formatted(.dateTime.hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits).locale(Locale(identifier: "en_US_POSIX")))
    }

    /// 월 일 (요일) 포맷 (예: "10월 30일 (목)")
    var monthDayWeekday: String {
        formatted(
            .dateTime
            .month(.defaultDigits)
            .day(.defaultDigits)
            .weekday(.abbreviated)
            .locale(Locale(identifier: "ko_KR"))
        )
    }
}
