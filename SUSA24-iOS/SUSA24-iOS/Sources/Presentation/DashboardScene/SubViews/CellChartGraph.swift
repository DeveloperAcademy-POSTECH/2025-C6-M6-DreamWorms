//
//  CellChartGraph.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Charts
import SwiftUI

struct CellChartGraph: View {
    let series: [HourlyVisit]
    let tickHours: [Int]
    let weekStyleScale: KeyValuePairs<String, Color>
    
    private func weekLabel(for weekIndex: Int) -> String {
        "\(weekIndex)주차"
    }
    
    var body: some View {
        Chart(series, id: \.id) { item in
            LineMark(
                x: .value("Hour", item.hour),
                y: .value("Visits", item.count),
                series: .value("Week", weekLabel(for: item.weekIndex))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(by: .value("Week", weekLabel(for: item.weekIndex)))
        }
        .chartLegend(.hidden)
        .chartForegroundStyleScale(weekStyleScale)
        .chartXAxis {
            AxisMarks(values: tickHours) { value in
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text(String(format: "%02d", v))
                            .font(.numberMedium12)
                            .foregroundStyle(.labelAssistive)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in AxisGridLine() }
        }
        .chartYScale(domain: 0 ... 11)
        .overlay {
            TimeLineEmptyState(message: .dashboardEmptyChartMessage)
                .setupFont(.bodyMedium12)
                .opacity(series.isEmpty ? 1 : 0)
        }
    }
}

//fileprivate enum CellChartGraphPreviewData {
//    static let tickHours = Array(stride(from: 0, through: 21, by: 3))
//    static let weekStyleScale: KeyValuePairs<String, Color> = [
//        "1주차": .primaryNormal,
//        "2주차": .primaryLight1,
//        "3주차": .primaryStrong,
//        "4주차": .primaryLight2,
//    ]
//    
//    // 주소 A: 오전 출근형 패턴
//    static let seriesA: [HourlyVisit] = [
//        HourlyVisit(weekIndex: 1, weekday: .mon, hour: 8, count: 3),
//        HourlyVisit(weekIndex: 1, weekday: .mon, hour: 9, count: 2),
//        HourlyVisit(weekIndex: 2, weekday: .mon, hour: 8, count: 4),
//        HourlyVisit(weekIndex: 2, weekday: .mon, hour: 9, count: 3),
//    ]
//    
//    // 주소 B: 야간 체류형 패턴
//    static let seriesB: [HourlyVisit] = [
//        HourlyVisit(weekIndex: 1, weekday: .mon, hour: 8, count: 4),
//        HourlyVisit(weekIndex: 1, weekday: .mon, hour: 9, count: 3),
//        HourlyVisit(weekIndex: 1, weekday: .fri, hour: 10, count: 2),
//        HourlyVisit(weekIndex: 1, weekday: .fri, hour: 11, count: 3),
//        
//        HourlyVisit(weekIndex: 2, weekday: .mon, hour: 8, count: 8),
//        HourlyVisit(weekIndex: 2, weekday: .mon, hour: 9, count: 3),
//        HourlyVisit(weekIndex: 2, weekday: .fri, hour: 10, count: 5),
//        HourlyVisit(weekIndex: 2, weekday: .fri, hour: 11, count: 5),
//        HourlyVisit(weekIndex: 2, weekday: .fri, hour: 12, count: 5),
//    ]
//    
//    // 주소 C: 주말 분산형 패턴
//    static let seriesC: [HourlyVisit] = [
//        HourlyVisit(weekIndex: 1, weekday: .mon, hour: 8, count: 1),
//        HourlyVisit(weekIndex: 1, weekday: .mon, hour: 9, count: 1),
//        HourlyVisit(weekIndex: 1, weekday: .fri, hour: 10, count: 1),
//        HourlyVisit(weekIndex: 1, weekday: .fri, hour: 11, count: 10),
//        
//        HourlyVisit(weekIndex: 2, weekday: .mon, hour: 8, count: 8),
//        HourlyVisit(weekIndex: 2, weekday: .mon, hour: 9, count: 3),
//        HourlyVisit(weekIndex: 2, weekday: .fri, hour: 10, count: 5),
//        HourlyVisit(weekIndex: 2, weekday: .fri, hour: 11, count: 0),
//        HourlyVisit(weekIndex: 2, weekday: .fri, hour: 12, count: 0),
//    ]
//}
//
//fileprivate struct CellChartGraphWithPickerPreview: View {
//    @State private var selection: Int = 0
//    
//    private var currentSeries: [HourlyVisit] {
//        switch selection {
//        case 0: return CellChartGraphPreviewData.seriesA
//        case 1: return CellChartGraphPreviewData.seriesB
//        case 2: return CellChartGraphPreviewData.seriesC
//        default: return []
//        }
//    }
//    
//    private var currentTitle: String {
//        switch selection {
//        case 0: return "퇴계로20길 56 (출근 패턴)"
//        case 1: return "을지로 밤거리 (야간 체류)"
//        case 2: return "주말 카페 밀집지"
//        default: return ""
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Picker("주소", selection: $selection) {
//                Text("주소 A").tag(0)
//                Text("주소 B").tag(1)
//                Text("주소 C").tag(2)
//            }
//            .pickerStyle(.segmented)
//            .padding(.horizontal, 16)
//            
//            Text(currentTitle)
//                .font(.bodyMedium14)
//                .foregroundStyle(.labelNeutral)
//            
//            CellChartGraph(
//                series: currentSeries,
//                tickHours: CellChartGraphPreviewData.tickHours,
//                weekStyleScale: CellChartGraphPreviewData.weekStyleScale
//            )
//            .frame(height: 220)
//            .padding(.horizontal, 16)
//            // 전환 애니메이션을 의도적으로 부드럽게 (또는 .transaction에서 nil로 꺼도 됨)
//            .animation(.easeInOut(duration: 0.25), value: selection)
//        }
//        .padding(.vertical, 24)
//    }
//}
//
//#Preview("CellChartGraph – Picker 기반 데이터 변경") {
//    CellChartGraphWithPickerPreview()
//}
