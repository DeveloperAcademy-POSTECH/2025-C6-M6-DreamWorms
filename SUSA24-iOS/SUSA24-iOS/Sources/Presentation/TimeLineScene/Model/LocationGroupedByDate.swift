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

// MARK: - 변환 로직
extension LocationGroupedByDate {
    /// Location 배열을 날짜별로 그룹화
    /// - Parameter locations: CoreData에서 가져온 Location 배열
    /// - Returns: 날짜별로 그룹화된 LocationGroupedByDate 배열
    static func groupByDate(_ locations: [Location]) -> [LocationGroupedByDate] {
        // 1. 기지국만 필터링 + receivedAt 기준으로
        let filtered = locations.filter {
            $0.locationType == 2 && $0.receivedAt != nil
        }
        
        // 2. 날짜별로 그룹화 (시작 시간으로 만들어서 key값을 동일하게 날짜데이터로 뽑는다.)
        let grouped = Dictionary(grouping: filtered) { location -> Date in
            guard let receivedAt = location.receivedAt else { return Date() }
            // 시간을 00:00:00으로 정규화 (같은 날짜끼리 묶기)
            return Calendar.current.startOfDay(for: receivedAt)
        }
        
        // 3. LocationGroupedByDate로 변환 ( map을 활용해서 key, locations를 평탄화 )
        // 다음 시간 순으로 최신순하고 구조체에 담기
        let result = grouped.map { (date, locations) -> LocationGroupedByDate in
            // 시간순으로 정렬 (최신순)
            let sorted = locations.sorted() {
                ($0.receivedAt ?? Date()) > ($1.receivedAt ?? Date())
            }
            return LocationGroupedByDate(date: date, locations: sorted)
        }
        
        // 4. 날짜 기준 내림차순 정렬 (최신 날짜가 위로)
        return result.sorted { $0.date > $1.date }
    }
}
