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
            
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                
                HStack(spacing: 6) {
                    Capsule()
                        .fill(.primaryNormal)
                        .frame(width: 10, height: 3)
                    Text("1주차")
                        .font(.bodyMedium10)
                        .foregroundStyle(.labelNormal)
                }
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
            .chartForegroundStyleScale([
                "1주차": .primaryNormal,
                "2주차": .primaryLight1,
                "3주차": .primaryStrong,
                "4주차": .primaryLight2,
            ])
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
            .overlay {
                Text(.dashboardEmptyChartMessage)
                    .font(.bodyMedium12)
                    .foregroundStyle(.labelAlternative)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    @Previewable @State var selectionWeekday: Weekday = .mon
    ZStack {
        Color.mainAlternative.ignoresSafeArea()
        
        VStack(spacing: 12) {
            CellHourlyChart(selectionWeekday: $selectionWeekday, address: "퇴계로20길 56", summary: "오전 7-8시에 주로 머물렀습니다.", series: [
                HourlyVisit(weekLabel: "1주차", hour: 1, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 2, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 3, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 4, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 5, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 6, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 7, count: 8),
                HourlyVisit(weekLabel: "1주차", hour: 8, count: 0),
                HourlyVisit(weekLabel: "1주차", hour: 9, count: 0),
                HourlyVisit(weekLabel: "1주차", hour: 10, count: 0),
                HourlyVisit(weekLabel: "1주차", hour: 11, count: 1),
                HourlyVisit(weekLabel: "1주차", hour: 12, count: 5),
                HourlyVisit(weekLabel: "1주차", hour: 13, count: 0),
                HourlyVisit(weekLabel: "1주차", hour: 14, count: 0),
                HourlyVisit(weekLabel: "1주차", hour: 15, count: 0),
                HourlyVisit(weekLabel: "1주차", hour: 16, count: 0),
                HourlyVisit(weekLabel: "1주차", hour: 17, count: 8),
                HourlyVisit(weekLabel: "1주차", hour: 18, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 19, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 20, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 21, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 22, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 23, count: 12),
                HourlyVisit(weekLabel: "1주차", hour: 24, count: 12),
            ])
            
            CellHourlyChart(selectionWeekday: $selectionWeekday, series: [
            ])
        }
        .padding(.horizontal, 16)
    }
}
