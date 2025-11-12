//
//  LocationGroupedByDate.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import Foundation
import SwiftUI

// MARK: - 날짜별 그룹화 모델

/// 날짜별로 그룹화된 위치정보
struct LocationGroupedByDate: Identifiable, Equatable, Sendable {
    let id = UUID()
    let date: Date
    let locations: [Location]
    let consecutiveGroups: [ConsecutiveLocationGroup]
    
    /// 섹션 헤더 텍스트 ( 예: "10월 30일 (목) " )
    var headerText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    /// 스크롤 ID로 사용할 String ID (예: "2025-01-06")
    var dateID: String {
        Self.dateToID(date)
    }
    
    static func dateToID(_ date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day
        else {
            return ""
        }
        
        return String(format: "%04d-%02d-%02d", year, month, day)
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

        guard !filtered.isEmpty else { return [] }

        // 2. 전체 주소별 방문 횟수 계산 (TOP 3 결정용)
        var addressVisitCounts: [String: Int] = [:]
        for location in filtered {
            addressVisitCounts[location.address, default: 0] += 1
        }

        // 3. TOP 3 주소 찾기
        let top3Addresses = addressVisitCounts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        // 4. 주소에 따른 state 결정 함수
        func determineState(for address: String) -> TimeLineColorStickState {
            guard let index = top3Addresses.firstIndex(of: address) else {
                return .normal
            }
            switch index {
            case 0: return .top1
            case 1: return .top2
            case 2: return .top3
            default: return .normal
            }
        }

        // 5. 날짜별로 그룹화
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filtered) { location -> Date in
            guard let receivedAt = location.receivedAt else { return Date() }
            return calendar.startOfDay(for: receivedAt)
        }

        // 6. LocationGroupedByDate로 변환
        let result = grouped.map { date, locations -> LocationGroupedByDate in
            let sorted = locations.sorted {
                ($0.receivedAt ?? Date()) > ($1.receivedAt ?? Date())
            }
            let groups = makeConsecutiveGroups(sorted, stateResolver: determineState)

            return LocationGroupedByDate(
                date: date,
                locations: sorted,
                consecutiveGroups: groups
            )
        }

        // 7. 날짜 기준 내림차순 정렬
        return result.sorted { $0.date > $1.date }
    }
    
    //MARK: - 연속 그룹 생성

    private static func makeConsecutiveGroups(
        _ locations: [Location],
        stateResolver: (String) -> TimeLineColorStickState
    ) -> [ConsecutiveLocationGroup] {
        guard !locations.isEmpty else { return [] }

        var groups: [ConsecutiveLocationGroup] = []
        var batch: [Location] = [locations[0]]
        var addr = locations[0].address

        for loc in locations.dropFirst() {
            if loc.address == addr {
                batch.append(loc)
            } else {
                let state = stateResolver(addr)
                groups.append(ConsecutiveLocationGroup(
                    address: addr,
                    locations: batch,
                    state: state
                ))
                // 새 배치 시작
                batch = [loc]
                addr = loc.address
            }
        }
        let state = stateResolver(addr)
        groups.append(ConsecutiveLocationGroup(
            address: addr,
            locations: batch,
            state: state
        ))
        return groups
    }
}
