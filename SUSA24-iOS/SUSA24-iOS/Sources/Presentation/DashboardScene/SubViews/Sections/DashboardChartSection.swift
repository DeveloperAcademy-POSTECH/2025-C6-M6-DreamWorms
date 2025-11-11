//
//  DashboardChartSection.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import SwiftUI

struct DashboardChartSection: View {
    let cellCharts: [CellChartData]
    let send: (DashboardFeature.Action) -> Void
    
    var body: some View {
        VStack {
            DashboardSectionHeader(
                title: String(localized: .dashboardVisitDurationCellTowerTitle)
            )
            .padding(.top, 20)
            .padding(.bottom, 17)
            .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                if cellCharts.isEmpty {
                    TimeLineEmptyState(message: .bottomSheetNoCellData)
                } else {
                    ForEach(cellCharts.prefix(3)) { chart in
                        let binding = Binding<Weekday>(
                            get: {
                                cellCharts.first(
                                    where: { $0.id == chart.id }
                                )?.selectedWeekday ?? .mon
                            },
                            set: { newValue in
                                send(.setChartWeekday(id: chart.id, weekday: newValue))
                            }
                        )

                        CellChartCard(
                            selectionWeekday: binding,
                            address: chart.address,
                            summary: chart.summary,
                            series: chart.series
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// #Preview {
//    DashboardChartSection(cellCharts: [], send: {  _ in })
// }
