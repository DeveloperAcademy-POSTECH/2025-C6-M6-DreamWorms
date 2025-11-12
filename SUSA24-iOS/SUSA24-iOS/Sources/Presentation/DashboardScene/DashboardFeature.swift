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
            if state.caseID == caseID, state.hasLoaded { return .none }
            
            state.caseID = caseID
            state.hasLoaded = false
            
            return .task { [repository] in
                do {
                    let locations = try await repository.fetchLocations(caseId: caseID)
                    let top3Locations = await locations.topAddressStays()
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
            state.cellCharts[index].selectedWeekday = weekday
            return .none
        }
    }
}

// MARK: - Private Extensions

private extension DashboardFeature {}

private extension Array<Location> {
    /// 기지국 데이터(locationType == 2)를 대상으로, 주소별 체류시간(분)을 누적해 상위 K개 반환
    ///
    /// 이 메서드는 원본 위치 데이터 배열에서 기지국(셀타워) 데이터만 필터링하고,
    /// 동일 주소에 대해 관측 횟수를 합산한 뒤, `sampleMinutes` (간격)을 곱해 추정 체류 시간(분)으로 변환합니다.
    ///
    /// - Returns: 주소와 총 체류 시간을 담은 `StayAddress` 배열. 최대 `topK`개까지 반환됩니다.
    func topAddressStays(
        sampleMinutes: Int = 5,
        topK: Int = 3
    ) -> [StayAddress] {
        let bucket = filter { $0.locationType == 2 }
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
    
    /// 주어진 위치 데이터에서 상위 K개 기지국 주소를 기준으로,
    /// 각 주소에 대한 요일·시간대·주차별 방문 패턴을 `CellChartData` 형태로 생성합니다.
    ///
    /// 이 메서드는:
    /// 1. 기지국 데이터(`locationType == 2`)에 대해 기간(주차 수)을 계산하고,
    /// 2. 상위 K개의 주소를 선정한 뒤,
    /// 3. 각 주소에 대해 `hourlySeriesForAllWeekdays`를 호출하여 시간대별 방문 시리즈를 만들고,
    /// 4. 주어진 `initialWeekday`를 기준으로 초기 선택 요일을 설정한 `CellChartData`를 반환합니다.
    ///
    /// - Parameters:
    ///   - topK: 상위 몇 개 주소에 대해 차트를 생성할지 여부. 기본값은 3입니다.
    ///   - maxWeeks: 최대 고려할 주차 수. 기본값은 4주입니다.
    /// - Returns: 각 주소별 시간대 패턴을 포함한 `CellChartData` 배열.
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
            
            return CellChartData(
                address: address,
                allSeries: allSeries,
                initialWeekday: initialWeekday
            )
        }
    }
    
    /// 기지국(Location) 데이터에서 상위 K개의 셀타워 주소 목록을 반환합니다.
    ///
    /// 이 메서드는 `locationType == 2` 인 항목만을 대상으로,
    /// 주소 문자열(비어 있는 경우 "기지국 주소"로 대체)을 기준으로 그룹화한 뒤
    /// 관측 횟수가 많은 순서대로 상위 K개의 주소를 추립니다.
    ///
    /// - Parameter topK: 반환할 상위 주소 개수. 기본값은 3입니다.
    /// - Returns: 셀타워 주소 문자열 배열.
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
    
    /// 특정 주소에 대해, 주차·요일·시간별 방문 횟수를 `HourlyVisit` 시리즈로 생성합니다.
    ///
    /// 내부적으로 다음 로직을 수행합니다:
    /// - 주소와 `locationType == 2` 조건에 맞는 Location만 필터링
    /// - 기준 주 시작일(`baseWeekStart`)로부터의 일 수 차이를 통해 `weekIndex` 계산
    /// - `Weekday` 및 시(hour) 단위로 그룹화 후 카운트 누적
    /// - 1주차부터 `maxWeeks`까지, 모든 요일과 0~23시 조합에 대해 누락된 값은 0으로 채워 반환
    ///
    /// 이 결과는 차트에서 주별/요일별/시간대별 라인 그래프를 일관되게 그리기 위한
    /// 균일한 그리드 형태의 데이터로 사용됩니다.
    ///
    /// - Parameters:
    ///   - address: 대상이 되는 셀타워 주소.
    ///   - baseWeekStart: 주차 계산의 기준이 되는 시작 날짜.
    ///   - maxWeeks: 생성할 최대 주차 수.
    /// - Returns: 주차(`weekIndex`), 요일(`weekday`), 시간(`hour`)별 방문 수(`count`)를 담은 `HourlyVisit` 배열.
    func hourlySeriesForAllWeekdays(
        for address: String,
        baseWeekStart: Date,
        maxWeeks: Int
    ) -> [HourlyVisit] {
        let calendar = Calendar.current
        let normalized = address.isEmpty ? "기지국 주소" : address
        
        var buckets: [Int: [Weekday: [Int: Int]]] = [:] // [주차: [요일: [시간: 카운트]]]
        
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

extension Array<HourlyVisit> {
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
