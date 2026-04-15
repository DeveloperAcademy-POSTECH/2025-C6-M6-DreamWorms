//
//  Date+Format.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import Foundation

// MARK: - Date Extension

extension Date {
    /// 재사용되는 DateFormatter (static 캐싱으로 매번 생성 방지)
    private static let chipFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M.d"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let headerFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M월 d일 (E)"
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = .current
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm a"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// 월.일 포맷 (예: "11.8")
    var monthDay: String {
        Self.chipFormatter.string(from: self)
    }

    /// 시:분 포맷 (예: "13:44 PM")
    var hourMinute: String {
        Self.timeFormatter.string(from: self)
    }

    /// 월 일 (요일) 포맷 (예: "11월 11일 (화)")
    var monthDayWeekday: String {
        Self.headerFormatter.string(from: self)
    }
}
