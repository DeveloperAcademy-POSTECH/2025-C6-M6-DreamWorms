//
//  HourlyVisit.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Foundation

struct HourlyVisit: Identifiable, Hashable {
    let weekIndex: Int
    let weekday: Weekday
    let hour: Int
    let count: Int
    
    /// 같은 주차(weekIndex), 같은 요일(weekday), 같은 시간(hour) 조합은 동일한 데이터로 취급하기 위한 id 값
    /// Swift Chart ForEach에서 반복 렌더링하기 위함.
    var id: String { "\(weekIndex)-\(hour)" }
}

extension Array<HourlyVisit> {
    /// 시계열 방문 데이터(`HourlyVisit`)를 요약 문장으로 변환합니다.
    /// - Returns: “오전 8시–오전 9시에 주로 머물렀습니다.” 형태의 설명 문자열
    func makeHourlySummary() -> String {
        guard let latestWeekIndex = latestWeekIndexWithVisits() else { return "" }
        guard let bestVisit = bestVisitInWeek(weekIndex: latestWeekIndex) else { return "" }
        return makeHourRangeSummary(fromHour: bestVisit.hour)
    }
    
    /// 24시간 형식의 시(hour)를 한국어 표현으로 변환합니다.
    ///
    /// - Parameter hour: 24시간 형식의 시 (0–23)
    /// - Returns: “오전 8시”, “오후 3시” 같은 문자열
    func hourText(from hour: Int) -> String {
        switch hour {
        case 0: "오전 0시"
        case 1 ..< 12: "오전 \(hour)시"
        case 12: "오후 12시"
        default: "오후 \(hour - 12)시"
        }
    }
}

private extension Array<HourlyVisit> {
    /// 방문 데이터가 존재하는 가장 최신 주차 인덱스를 찾습니다.
    /// - Returns: 최신 주차 인덱스 (없으면 nil)
    func latestWeekIndexWithVisits() -> Int? {
        filter { $0.count > 0 }
            .map(\.weekIndex)
            .max()
    }
    
    /// 특정 주차에서 방문 횟수가 가장 많은 시간대를 찾습니다.
    ///
    /// - Parameter weekIndex: 조회할 주차 인덱스
    /// - Returns: 가장 많이 방문한 시간대의 `HourlyVisit` (없으면 nil)
    func bestVisitInWeek(weekIndex: Int) -> HourlyVisit? {
        let candidates = filter {
            $0.weekIndex == weekIndex && $0.count > 0
        }
        return candidates.max(by: { $0.count < $1.count })
    }
    
    /// 시작 시간을 기준으로 “오전 h시–오전 h시” 형식의 요약 문장을 생성합니다.
    ///
    /// - Parameter fromHour: 시작 시간 (0–23)
    /// - Returns: 시간대 요약 문장
    func makeHourRangeSummary(fromHour: Int) -> String {
        let startHour = fromHour
        let endHour = (fromHour + 1) % 24
        
        let startText = hourText(from: startHour)
        let endText = hourText(from: endHour)
        
        return "\(startText)-\(endText)에 주로 머물렀습니다."
    }
}
