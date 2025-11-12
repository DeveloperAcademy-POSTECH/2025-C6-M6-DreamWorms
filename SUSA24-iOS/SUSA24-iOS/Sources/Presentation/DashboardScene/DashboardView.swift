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
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            DashboardHeader(
                // TODO: - 추후 Foundation Model 연동시 수정 필요
                title: String(localized: .testAnalyze),
                onBack: { coordinator.pop() }
            )
            
            ScrollView {
                DashboardRankSection(
                    currentTab: Binding(
                        get: { store.state.tab },
                        set: { store.send(.setTab($0)) }
                    ),
                    topLocations: store.state.topVisitDurationLocations
                )
                .padding(.bottom, 34)
                .padding(.horizontal, 16)
                                
                DashboardChartSection(
                    cellCharts: store.state.cellCharts,
                    send: { store.send($0) }
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

private extension DashboardView {}

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
