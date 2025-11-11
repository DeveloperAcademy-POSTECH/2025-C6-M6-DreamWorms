//
//  DashboardRankSection.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import SwiftUI

struct DashboardRankSection: View {
    @Binding var currentTab: DashboardPickerTab
    let topLocations: [StayAddress]
    
    var body: some View {
        VStack {
            Picker("", selection: $currentTab) {
                ForEach(DashboardPickerTab.allCases, id: \.title) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 295)
            .padding(.bottom, 24)
            
            DashboardSectionHeader(title: currentTab.sectionTitle)
                .setupDescription(currentTab.sectionDescription)
                .padding(.bottom, 18)
            
            VStack(spacing: 6) {
                if topLocations.isEmpty {
                    TimeLineEmptyState(message: .bottomSheetNoCellData)
                } else {
                    ForEach(topLocations.enumerated(), id: \.offset) { index, item in
                        DWLocationCard(
                            type: .number(index),
                            title: item.address,
                            description: formatStay(item.totalMinutes)
                        )
                    }
                }
            }
        }
    }
}

private extension DashboardRankSection {
    /// minute값을 받으면 "19시간 10분 체류" 같이 사람이 읽기 쉬운 문자열로 바꿔주는 메서드
    private func formatStay(_ minutes: Int) -> String {
        let hour = minutes / 60
        let min = minutes % 60
        if hour > 0, min > 0 { return "\(hour)시간 \(min)분 체류" }
        if hour > 0 { return "\(hour)시간 체류" }
        return "\(min)분 체류"
    }
}

// #Preview {
//    @Previewable @State var currentTab: DashboardPickerTab = .visitDuration
//    DashboardRankSection(
//        currentTab: $currentTab,
//        topLocations: []
//    )
// }
