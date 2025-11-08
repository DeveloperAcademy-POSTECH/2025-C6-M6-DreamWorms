//
//  DashboardFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct DashboardFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    init(repository: LocationRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        var tab: DashboardPickerTab = .visitDuration
        var caseID: UUID?
        var topVisitDurationLocations = [StayAddress]()
        var cellCharts: [CellChartData] = []
        
        var locations: [Location] = []
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case setTab(DashboardPickerTab)
        case onAppear(UUID)
        case setInitialData(locations: [Location], top3: [StayAddress], chart: [CellChartData])
        case setChartWeekday(id: CellChartData.ID, weekday: Weekday)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .setTab(tab):
            state.tab = tab
            return .none
            
        case let .onAppear(caseID):
            state.caseID = caseID
            return .task { [repository] in
                do {
                    let locations = try await repository.fetchLocations(caseId: caseID)
                    let top3Locations = await topAddressStays(from: locations)
                    let chartLocations = await locations.buildCellChartData()
                    return .setInitialData(
                        locations: locations,
                        top3: top3Locations,
                        chart: chartLocations
                    )
                } catch {
                    return .none
                }
            }
            
        case let .setInitialData(locations, top3, charts):
            state.locations = locations
            state.topVisitDurationLocations = top3
            state.cellCharts = charts
            return .none
            
        case let .setChartWeekday(id, weekday):
            guard !state.locations.isEmpty else { return .none }

            // 공통 baseWeekStart 계산
            let cellLocations = state.locations.filter { $0.locationType == 2 }
            guard let firstDate = cellLocations.compactMap(\.receivedAt).min() else { return .none }

            let calendar = Calendar.current
            func startOfWeek(_ date: Date) -> Date {
                calendar.date(
                    from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                )!
            }
            let baseWeekStart = startOfWeek(firstDate)

            guard let index = state.cellCharts.firstIndex(where: { $0.id == id }) else {
                return .none
            }

            let address = state.cellCharts[index].address

            // 해당 차트(주소)에 대해 선택된 요일 기반 series/summary 재계산
            let newSeries = state.locations.hourlySeries(
                for: address,
                baseWeekStart: baseWeekStart,
                maxWeeks: 4,
                targetWeekday: weekday
            )
            let newSummary = state.locations.summary(for: newSeries)

            state.cellCharts[index].selectedWeekday = weekday
            state.cellCharts[index].series = newSeries
            state.cellCharts[index].summary = newSummary

            return .none
        }
    }
}

// MARK: - Private Extensions

private extension DashboardFeature {
    /// 기지국 데이터(locationType == 2)를 대상으로, 주소별 체류시간(분)을 누적해 상위 K개 반환하는 메서드
    func topAddressStays(
        from locations: [Location],
        sampleMinutes: Int = 5,
        topK: Int = 3
    ) -> [StayAddress] {
        let filteredLocations = locations.filter { $0.locationType == 2 }
        var bucket: [String: Int] = [:]
        
        for location in filteredLocations {
            let key = location.address.isEmpty ? "기지국 주소" : location.address
            bucket[key, default: 0] += 1
        }

        let stays = bucket.map { StayAddress(address: $0.key, totalMinutes: $0.value * sampleMinutes) }
        return stays.sorted { $0.totalMinutes > $1.totalMinutes }.prefix(topK).map(\.self)
    }
}

private extension Array<Location> {
    func buildCellChartData(
        topK: Int = 3,
        maxWeeks: Int = 4
    ) -> [CellChartData] {
        let cellLocations = filter { $0.locationType == 2 }
        guard let firstDate = cellLocations.compactMap(\.receivedAt).min() else { return [] }

        let calendar = Calendar.current
        func startOfWeek(_ date: Date) -> Date {
            calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            )!
        }
        let baseWeekStart = startOfWeek(firstDate)

        let addresses = topCellAddresses(topK: topK)

        return addresses.map { address in
            // 초기 요일: 가장 방문 많은 요일 or .mon
            let initialWeekday = mostActiveWeekday(
                for: address,
                baseWeekStart: baseWeekStart,
                maxWeeks: maxWeeks
            ) ?? .mon

            let series = hourlySeries(
                for: address,
                baseWeekStart: baseWeekStart,
                maxWeeks: maxWeeks,
                targetWeekday: initialWeekday
            )
            let summary = summary(for: series)

            return CellChartData(
                address: address,
                selectedWeekday: initialWeekday,
                summary: summary,
                series: series
            )
        }
    }

    func topCellAddresses(topK: Int) -> [String] {
        let cells = filter { $0.locationType == 2 }
        let buckets = Dictionary(grouping: cells) {
            $0.address.isEmpty ? "기지국 주소" : $0.address
        }
        return buckets
            .sorted { $0.value.count > $1.value.count }
            .prefix(topK)
            .map(\.key)
    }

    func hourlySeries(
        for address: String,
        baseWeekStart: Date,
        maxWeeks: Int,
        targetWeekday: Weekday
    ) -> [HourlyVisit] {
        let calendar = Calendar.current
        let normalizedAddress = address.isEmpty ? "기지국 주소" : address

        var buckets: [Int: [Int: Int]] = [:] // weekIndex -> hour -> count

        for loc in self {
            guard
                loc.locationType == 2,
                (loc.address.isEmpty ? "기지국 주소" : loc.address) == normalizedAddress,
                let ts = loc.receivedAt
            else { continue }

            let diffWeeks = calendar.dateComponents(
                [.weekOfYear],
                from: baseWeekStart,
                to: ts
            ).weekOfYear ?? 0
            let weekIndex = diffWeeks + 1
            guard (1 ... maxWeeks).contains(weekIndex) else { continue }

            let systemWeekday = calendar.component(.weekday, from: ts)
            guard let weekday = Weekday(systemWeekday: systemWeekday) else { continue }

            // 선택된 요일만 포함
            guard weekday == targetWeekday else { continue }

            let hour = calendar.component(.hour, from: ts)
            buckets[weekIndex, default: [:]][hour, default: 0] += 1
        }

        var result: [HourlyVisit] = []
        for weekIndex in 1 ... maxWeeks {
            for hour in 0 ... 23 {
                let count = buckets[weekIndex]?[hour] ?? 0
                result.append(
                    HourlyVisit(
                        weekIndex: weekIndex,
                        weekday: targetWeekday,
                        hour: hour,
                        count: count
                    )
                )
            }
        }
        return result
    }

    func summary(for series: [HourlyVisit]) -> String {
        // 1) count > 0 인 주차만 모아서 그 중 가장 늦은 주차 선택
        guard let latestWeek = series
            .filter({ $0.count > 0 })
            .map(\.weekIndex)
            .max()
        else { return "" }

        // 2) 그 주차에서 가장 많이 머문 시간대 찾기
        let candidates = series.filter { $0.weekIndex == latestWeek && $0.count > 0 }
        guard let best = candidates.max(by: { $0.count < $1.count }) else { return "" }

        let startHour = best.hour
        let endHour = (best.hour + 1) % 24

        func hourText(_ h: Int) -> String {
            switch h {
            case 0: "오전 0시"
            case 1 ..< 12: "오전 \(h)시"
            case 12: "오후 12시"
            default: "오후 \(h - 12)시"
            }
        }

        return "\(hourText(startHour))-\(hourText(endHour))에 주로 머물렀습니다."
    }

    /// 주소별로 가장 방문이 많은 요일을 찾아 초기 선택값으로 쓰기
    func mostActiveWeekday(
        for address: String,
        baseWeekStart: Date,
        maxWeeks: Int
    ) -> Weekday? {
        let calendar = Calendar.current
        let normalizedAddress = address.isEmpty ? "기지국 주소" : address

        var counts: [Weekday: Int] = [:]

        for loc in self {
            guard
                loc.locationType == 2,
                (loc.address.isEmpty ? "기지국 주소" : loc.address) == normalizedAddress,
                let ts = loc.receivedAt
            else { continue }

            let diffWeeks = calendar.dateComponents([.weekOfYear], from: baseWeekStart, to: ts).weekOfYear ?? 0
            let weekIndex = diffWeeks + 1
            guard (1 ... maxWeeks).contains(weekIndex) else { continue }

            guard let weekday = Weekday(systemWeekday: calendar.component(.weekday, from: ts)) else { continue }
            counts[weekday, default: 0] += 1
        }

        return counts.max(by: { $0.value < $1.value })?.key
    }
}
