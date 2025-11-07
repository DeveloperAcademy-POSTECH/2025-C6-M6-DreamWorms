//
//  Date+Format.swift
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
}
