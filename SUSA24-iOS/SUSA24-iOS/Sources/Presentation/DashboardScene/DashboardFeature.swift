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
        
        /// 현재 caseID에 대해 초기 데이터(fetch + 가공)가 완료되었는지 여부
        var hasLoaded: Bool = false
        
        /// 상단 TOP3 체류 기지국 카드 데이터
        var topVisitDurationLocations: [StayAddress] = []

        /// 시간대별 기지국 차트 카드 데이터
        var cellCharts: [CellChartData] = []

        /// 원본 Location 데이터 (필요시 추가 가공용)
        var locations: [Location] = []
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 상단 탭 변경
        case setTab(DashboardPickerTab)

        /// 화면 진입 시 호출 (데이터 로딩 트리거)
        case onAppear(UUID)

        /// 초기 데이터 세팅 (fetch + 가공 완료 후)
        case setInitialData(locations: [Location], top3: [StayAddress], chart: [CellChartData])

        /// 개별 차트에서 요일이 변경되었을 때
        case setChartWeekday(id: CellChartData.ID, weekday: Weekday)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .setTab(tab):
            state.tab = tab
            return .none
            
        case let .onAppear(caseID):
            // 동일 caseID에 대해 이미 초기 로딩을 끝냈다면, 불필요한 fetch 방지
            if state.caseID == caseID, state.hasLoaded { return .none }
            
            // caseID가 바뀌었거나 처음 진입한 경우 → 새로 로딩
            state.caseID = caseID
            state.hasLoaded = false
            
            // Location fetch → TOP3 + 차트 데이터 생성
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
                    // TODO: - 에러 상태 액션 분리해서 사용자에게 알려줄지 여부는 추후 결정
                    return .none
                }
            }
            
        case let .setInitialData(locations, top3, charts):
            state.locations = locations
            state.topVisitDurationLocations = top3
            state.cellCharts = charts
            state.hasLoaded = true
            return .none
            
        case let .setChartWeekday(id, weekday):
            guard let index = state.cellCharts.firstIndex(where: { $0.id == id }) else {
                return .none
            }

            var chart = state.cellCharts[index]
            let filtered = chart.allSeries.filter { $0.weekday == weekday }

            chart.selectedWeekday = weekday
            chart.series = filtered
            chart.summary = filtered.makeHourlySummary()
            
            state.cellCharts[index] = chart

            return .none
        }
    }
}

// MARK: - Private Extensions

private extension DashboardFeature {
    /// 기지국 데이터(locationType == 2)를 대상으로, 주소별 체류시간(분)을 누적해 상위 K개 반환
    func topAddressStays(
        from locations: [Location],
        sampleMinutes: Int = 5,
        topK: Int = 3
    ) -> [StayAddress] {
        let bucket = locations
            .filter { $0.locationType == 2 }
            .reduce(into: [String: Int]()) { result, location in
                let key = location.address.isEmpty ? "기지국 주소" : location.address
                result[key, default: 0] += 1
            }

        return bucket
            .map { StayAddress(address: $0.key, totalMinutes: $0.value * sampleMinutes) }
            .sorted { $0.totalMinutes > $1.totalMinutes }
            .prefix(topK)
            .map(\.self)
    }
}

private extension Array<Location> {
    func buildCellChartData(
        topK: Int = 3,
        maxWeeks: Int = 4
    ) -> [CellChartData] {
        let cells = filter { $0.locationType == 2 }
        guard
            let firstDate = cells.compactMap(\.receivedAt).min(),
            let lastDate = cells.compactMap(\.receivedAt).max()
        else { return [] }

        let calendar = Calendar.current
        let baseWeekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstDate)
        ) ?? firstDate

        let days = calendar.dateComponents([.day], from: baseWeekStart, to: lastDate).day ?? 0
        let actualWeeks = Swift.min(maxWeeks, days / 7 + 1)
        let addresses = topCellAddresses(topK: topK)

        return addresses.map { address in
            let allSeries = hourlySeriesForAllWeekdays(
                for: address,
                baseWeekStart: baseWeekStart,
                maxWeeks: actualWeeks
            )

            let today = Date()
            let initialWeekday = Weekday(
                systemWeekday: calendar.component(.weekday, from: today)
            ) ?? .mon

            let initialSeries = allSeries.filter { $0.weekday == initialWeekday }
            let summary = initialSeries.makeHourlySummary()

            return CellChartData(
                address: address,
                selectedWeekday: initialWeekday,
                allSeries: allSeries,
                series: initialSeries,
                summary: summary
            )
        }
    }

    func topCellAddresses(topK: Int) -> [String] {
        let cells = filter { $0.locationType == 2 }
        let grouped = Dictionary(grouping: cells) {
            $0.address.isEmpty ? "기지국 주소" : $0.address
        }

        return grouped
            .sorted { $0.value.count > $1.value.count }
            .prefix(topK)
            .map(\.key)
    }

    func hourlySeriesForAllWeekdays(
        for address: String,
        baseWeekStart: Date,
        maxWeeks: Int
    ) -> [HourlyVisit] {
        let calendar = Calendar.current
        let normalized = address.isEmpty ? "기지국 주소" : address

        // [주차: [요일: [시간: 카운트]]]
        var buckets: [Int: [Weekday: [Int: Int]]] = [:]

        for location in self where location.locationType == 2 {
            guard
                (location.address.isEmpty ? "기지국 주소" : location.address) == normalized,
                let time = location.receivedAt
            else { continue }

            let daysDiff = calendar.dateComponents([.day], from: baseWeekStart, to: time).day ?? 0
            let weekIndex = daysDiff / 7 + 1
            guard (1 ... maxWeeks).contains(weekIndex) else { continue }

            guard let weekday = Weekday(systemWeekday: calendar.component(.weekday, from: time)) else { continue }
            let hour = calendar.component(.hour, from: time)

            buckets[weekIndex, default: [:]][weekday, default: [:]][hour, default: 0] += 1
        }

        let validWeeks = buckets.keys.sorted()

        return validWeeks.flatMap { weekIndex in
            Weekday.allCases.flatMap { weekday in
                (0 ... 23).map { hour in
                    HourlyVisit(
                        weekIndex: weekIndex,
                        weekday: weekday,
                        hour: hour,
                        count: buckets[weekIndex]?[weekday]?[hour] ?? 0
                    )
                }
            }
        }
    }
}

private extension Array<HourlyVisit> {
    /// 시계열 방문 데이터(`HourlyVisit`)를 요약 문장으로 변환합니다.
    ///
    /// - Parameter series: 요약할 `HourlyVisit` 배열
    /// - Returns: “오전 8시–오전 9시에 주로 머물렀습니다.” 형태의 설명 문자열
    func makeHourlySummary() -> String {
        guard let latestWeek = filter({ $0.count > 0 }).map(\.weekIndex).max() else {
            return ""
        }

        let candidates = filter { $0.weekIndex == latestWeek && $0.count > 0 }
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
}
