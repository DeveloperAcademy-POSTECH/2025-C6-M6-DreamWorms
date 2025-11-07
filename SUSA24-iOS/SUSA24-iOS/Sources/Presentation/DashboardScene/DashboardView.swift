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
        ScrollView {
            VStack {
                Text(.testAnalyze)
                    .font(.titleSemiBold22)
                    .kerning(-0.44)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                
                Picker(
                    "",
                    selection: Binding(
                        get: { store.state.tab },
                        set: { store.send(.setTab($0)) }
                    )
                ) {
                    ForEach(DashboardPickerTab.allCases, id: \.title) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 295)
                .padding(.top, 38)
                
                // MARK: - 채류시간 순위 섹션
                
                DashboardSectionHeader(title: store.state.tab.sectionTitle)
                    .setupDescription(store.state.tab.sectionDescription)
                    .padding(.top, 24)
                
                VStack(spacing: 6) {
                    if store.state.topVisitDurationLocations.isEmpty {
                        // TODO: - 데이터 없을 때 어떻게 띄울까 ~~~
                    } else {
                        ForEach(
                            store.state.topVisitDurationLocations.enumerated(),
                            id: \.offset
                        ) { id, item in
                            LocationCard(
                                type: .number(id),
                                title: item.address,
                                description: formatStay(item.totalMinutes)
                            )
                        }
                    }
                }
                .padding(.top, 16)
                
                // MARK: - 기지국별 체류시간 섹션
                
                DashboardSectionHeader(title: String(localized: .dashboardVisitDurationCellTowerTitle))
                    .padding(.top, 20)
                
                // TODO: - Swift Chart
            }
            .padding(.horizontal, 16)
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
    /// "19시간 10분 체류" 같이 사람이 읽기 쉬운 문자열로 바꾸기
    func formatStay(_ minutes: Int) -> String {
        let hour = minutes / 60
        let min = minutes % 60
        if hour > 0, min > 0 { return "\(hour)시간 \(min)분 체류" }
        if hour > 0 { return "\(hour)시간 체류" }
        return "\(min)분 체류"
    }
}

//// MARK: - Preview
//
// #if DEBUG
// import SwiftUI
//
///// 프리뷰 전용 목업 레포지토리 (대시보드가 onAppear에서 불러가도록)
// private struct DesignMockLocationRepository: LocationRepositoryProtocol {
//    func fetchLocations(caseId: UUID) async throws -> [Location] {
//        var list: [Location] = []
//
//        // 주소 A: 7회 (샘플분=5 → 35분)
//        for i in 0..<20 {
//            list.append(
//                Location(
//                    id: UUID(),
//                    address: "태니네 집",
//                    title: "A-\(i)",
//                    note: nil,
//                    pointLatitude: 37.5759,
//                    pointLongitude: 126.9768,
//                    boxMinLatitude: nil, boxMinLongitude: nil,
//                    boxMaxLatitude: nil, boxMaxLongitude: nil,
//                    locationType: 2, // 👈 대시보드 집계 대상
//                    receivedAt: Date().addingTimeInterval(TimeInterval(-i * 300))
//                )
//            )
//        }
//
//        // 주소 B: 3회 (15분)
//        for i in 0..<3 {
//            list.append(
//                Location(
//                    id: UUID(),
//                    address: "노우네집",
//                    title: "B-\(i)",
//                    note: nil,
//                    pointLatitude: 37.5499,
//                    pointLongitude: 126.9149,
//                    boxMinLatitude: nil, boxMinLongitude: nil,
//                    boxMaxLatitude: nil, boxMaxLongitude: nil,
//                    locationType: 2,
//                    receivedAt: Date().addingTimeInterval(TimeInterval(-i * 600))
//                )
//            )
//        }
//
//        // 주소 C: 빈 주소(→ "기지국 주소"로 치환), 5회 (25분)
//        for i in 0..<5 {
//            list.append(
//                Location(
//                    id: UUID(),
//                    address: "미니네집",
//                    title: "C-\(i)",
//                    note: nil,
//                    pointLatitude: 37.56,
//                    pointLongitude: 126.99,
//                    boxMinLatitude: nil, boxMinLongitude: nil,
//                    boxMaxLatitude: nil, boxMaxLongitude: nil,
//                    locationType: 2,
//                    receivedAt: Date().addingTimeInterval(TimeInterval(-i * 900))
//                )
//            )
//        }
//
//        // 주소 D: 10회지만 타입 1 → 집계 제외
//        for i in 0..<10 {
//            list.append(
//                Location(
//                    id: UUID(),
//                    address: "태니네집",
//                    title: "D-\(i)",
//                    note: nil,
//                    pointLatitude: 37.5072,
//                    pointLongitude: 126.7214,
//                    boxMinLatitude: nil, boxMinLongitude: nil,
//                    boxMaxLatitude: nil, boxMaxLongitude: nil,
//                    locationType: 1, // 👈 제외 대상
//                    receivedAt: Date().addingTimeInterval(TimeInterval(-i * 1200))
//                )
//            )
//        }
//
//        return list.shuffled()
//    }
//
//    func deleteLocation(id: UUID) async throws {}
//    func createLocations(data: [Location], caseId: UUID) async throws {}
// }
//
// #Preview("Dashboard – LocationCard (TOP3)") {
//    DashboardView(
//        store: DWStore(
//            initialState: DashboardFeature.State(),
//            reducer: DashboardFeature(repository: DesignMockLocationRepository())
//        ),
//        currentCaseID: UUID()
//    )
//    .environment(AppCoordinator())
// }
// #endif
