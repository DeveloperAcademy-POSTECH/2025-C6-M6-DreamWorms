//
//  Date+.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation

public extension Date {
    // MARK: - Formatted Strings
    
    /// 포맷된 타임스탬프 (중간 날짜, 짧은 시간)
    // TODO: Date.now.formatted 방식 적용
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    /// 짧은 날짜 형식
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    /// 긴 날짜 형식
    var longDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    /// 시간만 표시
    var timeOnlyString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    /// 상대적 시간 표시 (예: 3분 전, 2시간 전)
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // MARK: - Date Comparisons
    
    /// 오늘인지 확인
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// 어제인지 확인
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// 이번 주인지 확인
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// 이번 달인지 확인
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// 이번 해인지 확인
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    // MARK: - Date Components
    
    /// 시간 구성 요소
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    /// 분 구성 요소
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
    
    /// 요일 (1: 일요일, 7: 토요일)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    /// 요일 문자열
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.weekdaySymbols[weekday - 1]
    }
    
    /// 짧은 요일 문자열
    var shortWeekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.shortWeekdaySymbols[weekday - 1]
    }
    
    // MARK: - Date Calculations
    
    /// 다른 날짜까지의 일수 차이
    func daysBetween(_ otherDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: otherDate)
        return components.day ?? 0
    }
    
    /// 다른 날짜까지의 시간 차이 (초)
    func secondsBetween(_ otherDate: Date) -> TimeInterval {
        otherDate.timeIntervalSince(self)
    }
    
    /// 시작일 기준
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 종료일 기준
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// 주의 시작일
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// 월의 시작일
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
}
