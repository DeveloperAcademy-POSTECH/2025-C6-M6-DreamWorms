//
//  LocationGroupedByDate.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import Foundation

// MARK: - 날짜별 그룹화 모델

/// 날짜별로 그룹화된 위치정보
struct LocationGroupedByDate: Identifiable, Equatable, Sendable {
    let id = UUID()
    let date: Date
    let locations: [Location]
    
    /// 섹션 헤더 텍스트 ( 예: "10월 30일 (목) " )
    
    var headerText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from:date)
    }
}
