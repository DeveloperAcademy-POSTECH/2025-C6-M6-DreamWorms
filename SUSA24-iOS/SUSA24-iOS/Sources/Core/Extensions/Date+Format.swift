//
//  Date+DateFormat.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import SwiftUI

// MARK: - Date Extension

extension Date {
    /// Date를 지정된 포맷의 문자열로 변환합니다.
    ///
    /// - Parameter format: 날짜 포맷 문자열
    /// - Returns: 포맷팅된 문자열
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(
            identifier: String(
                localized: .usVer
            )
        )
        return formatter.string(from: self)
    }
    
    /// Date를 월과 일만 "M.d" 형식으로 Date() 타입으로 빼옵니다.
    ///
    /// - Parameter dataText: 날짜 포맷 문자열
    /// - Returns: 포맷팅된 Date() 타입.
    func formattedDateType(_ dataText: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dataText
        let dateString = formatter.string(from: self)
        return formatter.date(from: dateString)
    }
}
