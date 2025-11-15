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
    let onCardTap: (StayAddress) -> Void
    
    private var sortedTopLocations: [StayAddress] {
        switch currentTab {
        case .visitDuration:
            topLocations.sorted { $0.totalMinutes > $1.totalMinutes }
        case .visitFrequency:
            topLocations.sorted { $0.visitCount > $1.visitCount }
        }
    }
    
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
                            description: description(for: item)
                        )
                        .setupOnTap { onCardTap(item) }
                    }
                }
            }
        }
    }
}

private extension DashboardRankSection {
    /// 체류/방문 탭에 따라 description 텍스트 분기
    func description(for item: StayAddress) -> String {
        switch currentTab {
        case .visitDuration:
            formatStay(item.totalMinutes)
        case .visitFrequency: // enum 케이스 이름 확인해서 맞게 변경
            formatVisitCount(item.visitCount)
        }
    }
    
    /// minute값을 받으면 "19시간 10분 체류" 같이 사람이 읽기 쉬운 문자열로 바꿔주는 메서드
    private func formatStay(_ minutes: Int) -> String {
        let hour = minutes / 60
        let min = minutes % 60
        if hour > 0, min > 0 { return "\(hour)시간 \(min)분 체류" }
        if hour > 0 { return "\(hour)시간 체류" }
        return "\(min)분 체류"
    }
    
    /// "n회 방문"으로 description에 명시할 수 있는 문자열로 바꿔주는 메서드
    func formatVisitCount(_ count: Int) -> String {
        "\(count)회 방문"
    }
}

// #Preview {
//    @Previewable @State var currentTab: DashboardPickerTab = .visitDuration
//    DashboardRankSection(
//        currentTab: $currentTab,
//        topLocations: []
//    )
// }
