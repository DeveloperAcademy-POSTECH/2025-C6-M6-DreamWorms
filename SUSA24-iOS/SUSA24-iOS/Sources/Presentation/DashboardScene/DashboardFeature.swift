//
//  DashboardFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct DashboardFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    private let analysisService: DashboardAnalysisServiceProtocol
    
    init(
        repository: LocationRepositoryProtocol,
        analysisService: DashboardAnalysisServiceProtocol
    ) {
        self.repository = repository
        self.analysisService = analysisService
    }
    
    // MARK: - State
    
    struct State: DWState {
        var tab: DashboardPickerTab = .visitDuration
        var caseID: UUID?
        
        /// 현재 caseID에 대해 초기 데이터(fetch + 가공)가 완료되었는지 여부
        var hasLoaded: Bool = false
        
        /// 상단 TOP3 체류 시간 기지국 카드 데이터
        var topVisitDurationLocations: [StayAddress] = []
        
        /// 상단 TOP3 방문 빈도 기지국 카드 데이터
        var topVisitFrequencyLocations: [StayAddress] = []
        
        /// 시간대별 기지국 차트 카드 데이터
        var cellCharts: [CellChartData] = []
        
        /// 원본 Location 데이터 (필요시 추가 가공용)
        var locations: [Location] = []
        
        /// 체류시간 탭에서 사용할 헤더 문장
        var visitDurationSummary: String = ""
        
        /// 방문빈도 탭에서 사용할 헤더 문장
        var visitFrequencySummary: String = ""
        
        /// Foundation Models 분석 중 여부
        var isAnalyzingWithFM: Bool = false
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 상단 탭 변경
        case setTab(DashboardPickerTab)
        
        /// 화면 진입 시 호출 (데이터 로딩 트리거)
        case onAppear(UUID)
        
        /// 초기 데이터 세팅 (fetch + 가공 완료 후)
        case setInitialData(
            locations: [Location],
            topDuration: [StayAddress],
            topFrequency: [StayAddress],
            chart: [CellChartData]
        )
        
        /// 개별 차트에서 요일이 변경되었을 때
        case setChartWeekday(id: CellChartData.ID, weekday: Weekday)
        
        /// Foundation Model에게 상단 분석 문장 생성을 요청 (스트리밍 시작 트리거)
        case analyzeWithFoundationModel
        
        /// 스트리밍 도중, Foundation Model의 부분 생성 결과를 수신
        case updatePartialAnalysis(
            visitDurationSummary: String?,
            visitFrequencySummary: String?
        )
        
        /// 스트리밍 완료 후, 최종 결과 확정
        case setAnalysisResult(
            visitDurationSummary: String,
            visitFrequencySummary: String
        )
        
        /// Foundation Model 분석 실패
        case analysisFailed
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .setTab(tab):
            state.tab = tab
            guard state.hasLoaded, !state.locations.isEmpty else { return .none }
            
            switch tab {
            case .visitDuration:
                guard state.visitDurationSummary.isEmpty else { return .none }
                return .task { .analyzeWithFoundationModel }
            case .visitFrequency:
                guard state.visitFrequencySummary.isEmpty else { return .none }
                return .task { .analyzeWithFoundationModel }
            }

        case let .onAppear(caseID):
            if state.caseID == caseID, state.hasLoaded { return .none }
            
            state.caseID = caseID
            state.hasLoaded = false
            
            return .task { [repository] in
                do {
                    let locations = try await repository.fetchLocations(caseId: caseID)
                    let topDuration = await locations.topVisitDuration()
                    let topFrequency = await locations.topVisitFrequency()
                    let chartLocations = await locations.buildCellChartData()
                    
                    return .setInitialData(
                        locations: locations,
                        topDuration: topDuration,
                        topFrequency: topFrequency,
                        chart: chartLocations
                    )
                } catch {
                    return .none
                }
            }
            
        case let .setInitialData(locations, topDuration, topFrequency, charts):
            state.locations = locations
            state.topVisitDurationLocations = topDuration
            state.topVisitFrequencyLocations = topFrequency
            state.cellCharts = charts
            state.hasLoaded = true
            
            state.isAnalyzingWithFM = false
            state.visitDurationSummary = ""
            state.visitFrequencySummary = ""

            guard !locations.isEmpty else { return .none }
            return .task { .analyzeWithFoundationModel }
            
        case let .setChartWeekday(id, weekday):
            guard let index = state.cellCharts.firstIndex(where: { $0.id == id }) else {
                return .none
            }
            state.cellCharts[index].selectedWeekday = weekday
            return .none
            
        case .analyzeWithFoundationModel:
            guard !state.locations.isEmpty else { return .none }
            switch state.tab {
            case .visitDuration:
                state.isAnalyzingWithFM = true
                state.visitDurationSummary = "체류시간을 분석하고 있어요..."
                return makeVisitDurationEffect(
                    locations: state.locations,
                    topDuration: state.topVisitDurationLocations,
                    currentFrequencySummary: state.visitFrequencySummary
                )
            case .visitFrequency:
                state.isAnalyzingWithFM = true
                state.visitFrequencySummary = "방문 빈도를 분석하고 있어요..."
                return makeVisitFrequencyEffect(
                    locations: state.locations,
                    topFrequency: state.topVisitFrequencyLocations,
                    currentDurationSummary: state.visitDurationSummary
                )
            }
            
        case let .updatePartialAnalysis(visitDurationSummary, visitFrequencySummary):
            if let summary = visitDurationSummary {
                state.visitDurationSummary = summary
            }
            if let summary = visitFrequencySummary {
                state.visitFrequencySummary = summary
            }
            return .none
            
        case let .setAnalysisResult(visitDurationSummary, visitFrequencySummary):
            state.visitDurationSummary = visitDurationSummary
            state.visitFrequencySummary = visitFrequencySummary
            state.isAnalyzingWithFM = false
            return .none
            
        case .analysisFailed:
            state.isAnalyzingWithFM = false
            return .none
        }
    }
}

// MARK: - Private Extensions

private extension DashboardFeature {
    /// 체류시간 탭용 Foundation Model 스트림 Effect
    func makeVisitDurationEffect(
        locations: [Location],
        topDuration: [StayAddress],
        currentFrequencySummary: String
    ) -> DWEffect<Action> {
        DWEffect { [analysisService] downstream in
            do {
                let stream = await analysisService.streamVisitDurationAnalysis(
                    locations: locations,
                    topDuration: topDuration
                )
                
                var lastPartialDuration: String?
                
                for try await partial in stream {
                    let text = partial.title
                    lastPartialDuration = text
                    
                    downstream(
                        .updatePartialAnalysis(
                            visitDurationSummary: text,
                            visitFrequencySummary: nil
                        )
                    )
                }
                
                if let lastPartialDuration {
                    downstream(
                        .setAnalysisResult(
                            visitDurationSummary: lastPartialDuration,
                            visitFrequencySummary: currentFrequencySummary
                        )
                    )
                } else {
                    downstream(.analysisFailed)
                }
            } catch {
                downstream(.analysisFailed)
            }
        }
    }
    
    /// 방문빈도 탭용 Foundation Model 스트림 Effect
    func makeVisitFrequencyEffect(
        locations: [Location],
        topFrequency: [StayAddress],
        currentDurationSummary: String
    ) -> DWEffect<Action> {
        DWEffect { [analysisService] downstream in
            do {
                let stream = await analysisService.streamVisitFrequencyAnalysis(
                    locations: locations,
                    topFrequency: topFrequency
                )
                
                var lastPartialFrequency: String?
                
                for try await partial in stream {
                    let text = partial.title
                    lastPartialFrequency = text
                    
                    downstream(
                        .updatePartialAnalysis(
                            visitDurationSummary: nil,
                            visitFrequencySummary: text
                        )
                    )
                }
                
                if let lastPartialFrequency {
                    downstream(
                        .setAnalysisResult(
                            visitDurationSummary: currentDurationSummary,
                            visitFrequencySummary: lastPartialFrequency
                        )
                    )
                } else {
                    downstream(.analysisFailed)
                }
            } catch {
                downstream(.analysisFailed)
            }
        }
    }
}

private extension Array<Location> {
    /// 기지국(LocationType == 2) 데이터만을 대상으로,
    /// 주소별로 체류 시간 / 평균 좌표 / 방문 빈도(연속 구간 기준)를 집계합니다.
    ///
    /// - Parameter sampleIntervalMinutes: 한 샘플이 의미하는 시간(분 단위, 기본값 5분)
    /// - Returns: 주소별 요약 정보 `StayAddress` 배열
    func summarizedStays(sampleIntervalMinutes: Int = 5) -> [StayAddress] {
        // 1. 기지국만 필터링
        let cellLocations = filter { $0.locationType == 2 }
        guard !cellLocations.isEmpty else { return [] }
        
        // 2. 주소별 체류 시간(샘플 수) + 좌표 합계 계산
        //    - visitCount는 VisitFrequencyCalculator(연속 그룹 방식)에서 가져온다.
        var bucket: [String: (sampleCount: Int, latitudeSum: Double, longitudeSum: Double)] = [:]
        
        for location in cellLocations {
            let addressKey = location.address.isEmpty ? "기지국 주소" : location.address
            
            var entry = bucket[addressKey]
                ?? (sampleCount: 0, latitudeSum: 0, longitudeSum: 0)
            
            entry.sampleCount += 1
            entry.latitudeSum += location.pointLatitude
            entry.longitudeSum += location.pointLongitude
            
            bucket[addressKey] = entry
        }
        
        // 3. 연속 그룹 기준 방문 빈도 계산 (VisitFrequencyCalculator 활용)
        let visitFrequency = visitFrequencyByAddress() // [주소: 방문 횟수]
        
        // 4. 평균 좌표, 체류 시간(분), 방문 빈도를 사용해 StayAddress 배열 생성
        return bucket.map { address, value in
            let averageLatitude = value.latitudeSum / Double(value.sampleCount)
            let averageLongitude = value.longitudeSum / Double(value.sampleCount)
            let visitCount = visitFrequency[address] ?? 0
            
            return StayAddress(
                address: address,
                totalMinutes: value.sampleCount * sampleIntervalMinutes,
                latitude: averageLatitude,
                longitude: averageLongitude,
                visitCount: visitCount
            )
        }
    }
    
    /// 체류 시간 기준으로 상위 N개의 기지국을 반환합니다.
    func topVisitDuration(
        sampleIntervalMinutes: Int = 5,
        maxCount: Int = 3
    ) -> [StayAddress] {
        summarizedStays(sampleIntervalMinutes: sampleIntervalMinutes)
            .sorted { $0.totalMinutes > $1.totalMinutes }
            .prefix(maxCount)
            .map(\.self)
    }
    
    /// 방문 빈도 기준으로 상위 N개의 기지국을 반환합니다.
    /// 방문 빈도는 VisitFrequencyCalculator의 "연속 그룹" 방식을 사용합니다.
    func topVisitFrequency(
        sampleIntervalMinutes: Int = 5,
        maxCount: Int = 3
    ) -> [StayAddress] {
        summarizedStays(sampleIntervalMinutes: sampleIntervalMinutes)
            .sorted { $0.visitCount > $1.visitCount }
            .prefix(maxCount)
            .map(\.self)
    }
    
    /// 기지국 데이터에서 상위 몇 개 주소에 대해 시간대별 방문 패턴을 `CellChartData`로 생성합니다.
    ///
    /// - Parameters:
    ///   - maxAddressCount: 차트로 보여줄 상위 주소 개수
    ///   - maxWeeks: 최대 고려 주차 수
    func buildCellChartData(
        maxAddressCount: Int = 3,
        maxWeeks: Int = 4
    ) -> [CellChartData] {
        let cellLocations = filter { $0.locationType == 2 }
        guard
            !cellLocations.isEmpty,
            let firstDate = cellLocations.compactMap(\.receivedAt).min(),
            let lastDate = cellLocations.compactMap(\.receivedAt).max()
        else { return [] }
        
        let calendar = Calendar.current
        
        // 기준이 되는 "첫 주의 월요일(또는 해당 주 시작일)" 계산
        let baseWeekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstDate)
        ) ?? firstDate
        
        // 실제 존재하는 기간을 기준으로 몇 주치 데이터를 그릴지 계산
        let dayDifference = calendar.dateComponents([.day], from: baseWeekStart, to: lastDate).day ?? 0
        let actualWeeks = Swift.min(maxWeeks, dayDifference / 7 + 1)
        
        // 체류 시간 기준 상위 주소 목록만 추출
        let topAddresses = summarizedStays()
            .sorted { $0.totalMinutes > $1.totalMinutes }
            .prefix(maxAddressCount)
            .map(\.address)
        
        return topAddresses.map { address in
            let allSeries = hourlySeriesForAllWeekdays(
                for: address,
                baseWeekStart: baseWeekStart,
                maxWeeks: actualWeeks
            )
            
            // 초기 선택 요일은 "오늘" 기준
            let today = Date()
            let weekdayValue = calendar.component(.weekday, from: today)
            let initialWeekday = Weekday(systemWeekday: weekdayValue) ?? .mon
            
            return CellChartData(
                address: address,
                allSeries: allSeries,
                initialWeekday: initialWeekday
            )
        }
    }
    
    /// 특정 주소에 대해, 주차·요일·시간별 방문 횟수를 `HourlyVisit` 시리즈로 생성합니다.
    ///
    /// - Parameters:
    ///   - address: 대상이 되는 셀타워 주소
    ///   - baseWeekStart: 주차 계산의 기준이 되는 시작 날짜
    ///   - maxWeeks: 생성할 최대 주차 수
    func hourlySeriesForAllWeekdays(
        for address: String,
        baseWeekStart: Date,
        maxWeeks: Int
    ) -> [HourlyVisit] {
        let calendar = Calendar.current
        let normalizedAddress = address.isEmpty ? "기지국 주소" : address
        
        // [주차: [요일: [시간: 카운트]]] 구조로 집계
        var buckets: [Int: [Weekday: [Int: Int]]] = [:]
        
        for location in self where location.locationType == 2 {
            guard
                (location.address.isEmpty ? "기지국 주소" : location.address) == normalizedAddress,
                let timestamp = location.receivedAt
            else { continue }
            
            let daysFromBase = calendar.dateComponents([.day], from: baseWeekStart, to: timestamp).day ?? 0
            let weekIndex = daysFromBase / 7 + 1
            guard (1 ... maxWeeks).contains(weekIndex) else { continue }
            
            guard let weekday = Weekday(systemWeekday: calendar.component(.weekday, from: timestamp)) else {
                continue
            }
            let hour = calendar.component(.hour, from: timestamp)
            
            buckets[weekIndex, default: [:]][weekday, default: [:]][hour, default: 0] += 1
        }
        
        let validWeeks = buckets.keys.sorted()
        
        // 1주차부터 maxWeeks까지, 모든 요일·시간 조합을 채우되 값이 없으면 0으로 채움
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
