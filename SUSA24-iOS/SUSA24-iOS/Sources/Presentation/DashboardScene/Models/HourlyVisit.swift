//
//  HourlyVisit.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Foundation

struct HourlyVisit: Identifiable, Hashable {
    let id = UUID()
    let weekLabel: String // "1주차"(지난주), "2주차"(이번주)
    let hour: Int // 0...23
    let count: Int
}

enum AddressPickError: Error { case noCellLocations }

extension Array<Location> {
    /// locationType == 2(기지국) 중 가장 많이 등장한 address를 반환
    func mostVisitedCellAddress() throws -> String {
        let cells = filter { $0.locationType == 2 }
        guard !cells.isEmpty else { throw AddressPickError.noCellLocations }
        let buckets = Dictionary(grouping: cells, by: { $0.address.isEmpty ? "기지국 주소" : $0.address })
        return buckets.max(by: { $0.value.count < $1.value.count })!.key
    }

    /// 특정 address만 대상으로, 지난주/이번주 각각 시간대별 카운트를 계산
    /// - Parameters:
    ///   - address: 타겟 주소
    ///   - now: 기준 시간(기본 현재 시각)
    func hourlySeries(for address: String, now: Date = .init()) -> [HourlyVisit] {
        let cal = Calendar.current

        // 주의 시작(월요일 기준) 구하기
        func startOfWeek(_ d: Date) -> Date {
            cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: d))!
        }
        let startThisWeek = startOfWeek(now)
        guard let startLastWeek = cal.date(byAdding: .weekOfYear, value: -1, to: startThisWeek) else { return [] }
        let endThisWeek = cal.date(byAdding: .weekOfYear, value: 1, to: startThisWeek)! // 다음 주 시작 == 이번 주 끝

        // 필터: 해당 주소 & 기지국 & 지난주~이번주 범위
        let target = filter {
            $0.locationType == 2 &&
                ($0.address.isEmpty ? "기지국 주소" : $0.address) == address &&
                ($0.receivedAt ?? Date() >= startLastWeek && $0.receivedAt ?? Date() < endThisWeek)
        }

        // 주차 라벨러
        func weekLabel(_ d: Date) -> String {
            if d >= startThisWeek { return "2주차" } // 이번 주
            return "1주차" // 지난 주
        }

        // 시간대별 카운트
        var counter: [String: [Int: Int]] = ["1주차": [:], "2주차": [:]] // weekLabel -> hour -> count
        for loc in target {
            let h = cal.component(.hour, from: loc.receivedAt ?? Date())
            let wl = weekLabel(loc.receivedAt ?? Date())
            counter[wl, default: [:]][h, default: 0] += 1
        }

        // 0~23 모두 채워서 라인을 끊기지 않게
        var result: [HourlyVisit] = []
        for wl in ["1주차", "2주차"] {
            for hour in 0 ... 23 {
                let c = counter[wl]?[hour] ?? 0
                result.append(HourlyVisit(weekLabel: wl, hour: hour, count: c))
            }
        }
        return result
    }
}
