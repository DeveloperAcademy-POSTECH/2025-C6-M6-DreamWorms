//
//  CellHourlyChart.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import Charts
import SwiftUI

struct CellHourlyChart: View {
    @Binding var selectionWeekday: Weekday
    
    var address: String = ""
    var summary: String = ""
    let series: [HourlyVisit]
    
    private let tickHours = Array(stride(from: 0, through: 21, by: 3))
    private let weekStyleScale: KeyValuePairs<String, Color> = [
        "1주차": .primaryNormal,
        "2주차": .primaryLight1,
        "3주차": .primaryStrong,
        "4주차": .primaryLight2,
    ]
    private var availableWeeks: [Int] {
        let set = Set(series.map(\.weekIndex))
        return set.sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Title
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(address.isEmpty ? "이" : address) 기지국에서")
                    .font(.bodyMedium12)
                    .foregroundStyle(.primaryNormal)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 5)
                    .background(.primaryLight2)
                    .cornerRadius(4)
                
                Text("\(summary.isEmpty ? "주로 머무는 시간대를 확인하세요." : summary)")
                    .font(.titleSemiBold18)
                    .foregroundStyle(summary.isEmpty ? .labelAssistive : .labelNormal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
            
            // MARK: - Chart Legend
            
            HStack {
                Spacer()
                
                HStack(spacing: 10) {
                    ForEach(availableWeeks, id: \.self) { week in
                        HStack(spacing: 6) {
                            Capsule()
                                .fill(
                                    weekStyleScale.first(where: { $0.key == "\(week)주차" })?.value
                                        ?? .labelAssistive
                                ).frame(width: 10, height: 3)
                            Text("\(week)주차")
                                .font(.bodyMedium10)
                                .foregroundStyle(.labelNormal)
                        }
                    }
                }
                .opacity(series.isEmpty ? 0 : 1)
            }
            .padding(.bottom, series.isEmpty ? 0 : 16)
            .opacity(series.isEmpty ? 0 : 1)
            
            // MARK: - Chart
            
            Chart(series) { item in
                LineMark(
                    x: .value("Hour", item.hour),
                    y: .value("Visits", item.count),
                    series: .value("주차", item.weekLabel)
                )
                .foregroundStyle(by: .value("주차", item.weekLabel))
                .interpolationMethod(.catmullRom)
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
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                }
            }
            .chartYScale(domain: 0 ... 11)
            .overlay {
                TimeLineEmptyState(message: .dashboardEmptyChartMessage)
                    .setupFont(.bodyMedium12)
                    .opacity(series.isEmpty ? 1 : 0)
            }
            .frame(height: 142)
            .padding(.bottom, 18)
            
            // MARK: - Weekday Picker
            
            WeekdayPillPicker(selection: $selectionWeekday)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.mainBackground)
        .cornerRadius(12)
        .shadow(
            color: .black.opacity(0.05),
            radius: 12,
            x: 0,
            y: 2
        )
    }
}

//#Preview {
//    @Previewable @State var selectionWeekday: Weekday = .mon
//    ZStack {
//        Color.mainAlternative.ignoresSafeArea()
//        
//        VStack(spacing: 12) {
//            CellHourlyChart(selectionWeekday: $selectionWeekday, address: "퇴계로20길 56", summary: "오전 7-8시에 주로 머물렀습니다.", series: [
//                HourlyVisit(weekIndex: 1, weekday: .mon, hour: 1, count: 2)
//            ])
//            
//            CellHourlyChart(selectionWeekday: $selectionWeekday, series: [
//            ])
//        }
//        .padding(.horizontal, 16)
//    }
//}
