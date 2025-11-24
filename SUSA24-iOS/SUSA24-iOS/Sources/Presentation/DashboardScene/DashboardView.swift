//
//  DashboardView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var store: DWStore<DashboardFeature>
    
    // MARK: - Properties
    
    var currentCaseID: UUID
    
    private var headerTitle: String {
        if store.state.isAnalyzingWithFM {
            // 로딩 중일 때
            switch store.state.tab {
            case .visitDuration:
                store.state.visitDurationSummary.isEmpty
                    ? "체류시간을 분석하고 있어요..."
                    : store.state.visitDurationSummary
            case .visitFrequency:
                store.state.visitFrequencySummary.isEmpty
                    ? "방문 빈도를 분석하고 있어요..."
                    : store.state.visitFrequencySummary
            }
        } else {
            // 분석 완료 or 실패 후
            switch store.state.tab {
            case .visitDuration:
                store.state.visitDurationSummary.isEmpty
                    ? "체류시간 분석을 위한 데이터가 충분하지 않아요."
                    : normalizeTrailingDots(store.state.visitDurationSummary)
            case .visitFrequency:
                store.state.visitFrequencySummary.isEmpty
                    ? "방문빈도 분석을 위한 데이터가 충분하지 않아요."
                    : normalizeTrailingDots(store.state.visitFrequencySummary)
            }
        }
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            DashboardHeader(
                title: headerTitle,
                onBack: { coordinator.pop() }
            )
            
            ScrollView {
                DashboardRankSection(
                    currentTab: Binding(
                        get: { store.state.tab },
                        set: { store.send(.setTab($0)) }
                    ),
                    topVisitDurationLocations: store.state.topVisitDurationLocations,
                    topVisitFrequencyLocations: store.state.topVisitFrequencyLocations,
                    onCardTap: {
                        coordinator.push(
                            .locationOverviewScene(
                                caseID: currentCaseID,
                                address: $0.address,
                                initialCoordinate: MapCoordinate(latitude: $0.latitude, longitude: $0.longitude)
                            )
                        )
                    }
                )
                .padding(.bottom, 34)
                .padding(.horizontal, 16)
                                
                DashboardChartSection(
                    cellCharts: store.state.cellCharts,
                    send: { action in store.send(action) }
                )
                .padding(.bottom, 54)
                .background(.mainAlternative)
            }
        }
        .task {
            store.send(.onAppear(currentCaseID))
        }
    }
}

// MARK: - Extension Methods

extension DashboardView {}

// MARK: - Private Extension Methods

private extension DashboardView {
    /// 문장 끝의 `...`, `....` 같은 여러 개의 마침표를 단일 `.`로 정리합니다.
    func normalizeTrailingDots(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 끝에 2개 이상 붙은 마침표를 하나로 치환
        if let range = trimmed.range(of: #"\.{2,}$"#, options: .regularExpression) {
            var result = trimmed
            result.replaceSubrange(range, with: ".")
            return result
        }
        
        return trimmed
    }
}

// MARK: - Preview

// #if DEBUG
//    import SwiftUI
//
//    /// 프리뷰 전용 목업 레포지토리 (대시보드가 onAppear에서 불러가도록)
//    private struct DesignMockLocationRepository: LocationRepositoryProtocol {
//        func fetchLocations(caseId _: UUID) async throws -> [Location] {
//            let list: [Location] = [
//                Location(id: UUID(), address: "미니네 천안 집", pointLatitude: 37.5759, pointLongitude: 126.9768, locationType: 2, colorType: 0, receivedAt: Date.now),
//            ]
//            return list
//        }
//
//        func deleteLocation(id _: UUID) async throws {}
//        func createLocations(data _: [Location], caseId _: UUID) async throws {}
//        func fetchNoCellLocations(caseId _: UUID, locationType _: [Int]) async throws -> [Location] { [] }
//    }
//
//    #Preview("Dashboard – LocationCard (TOP3)") {
//        DashboardView(
//            store: DWStore(
//                initialState: DashboardFeature.State(),
//                reducer: DashboardFeature(repository: DesignMockLocationRepository())
//            ),
//            currentCaseID: UUID()
//        )
//        .environment(AppCoordinator())
//    }
// #endif
