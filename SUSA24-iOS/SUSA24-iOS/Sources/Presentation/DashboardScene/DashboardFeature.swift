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
