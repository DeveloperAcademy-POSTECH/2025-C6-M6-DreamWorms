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

    /// 단일 선택된 시간 (부모와 공유)
    @Binding var selectedHour: Int?

    private func weekLabel(for weekIndex: Int) -> String {
        "\(weekIndex)주차"
    }

    /// 현재 시리즈에서 실제 존재하는 hour 집합
    private var availableHours: [Int] {
        Array(Set(series.map(\.hour))).sorted()
    }

    /// chartXSelection(value:)에서 들어온 값을 실제 hour로 스냅
    private var snappedHourBinding: Binding<Int?> {
        Binding(
            get: { selectedHour },
            set: { newValue in
                guard let raw = newValue else {
                    selectedHour = nil
                    return
                }

                guard !availableHours.isEmpty else {
                    selectedHour = nil
                    return
                }

                let nearest = availableHours.min { lhs, rhs in
                    abs(lhs - raw) < abs(rhs - raw)
                }

                selectedHour = nearest
            }
        )
    }

    var body: some View {
        Chart {
            ForEach(series, id: \.id) { item in
                LineMark(
                    x: .value("Hour", item.hour),
                    y: .value("Visits", item.count),
                    series: .value("Week", weekLabel(for: item.weekIndex))
                )
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(by: .value("Week", weekLabel(for: item.weekIndex)))

                PointMark(
                    x: .value("Hour", item.hour),
                    y: .value("Visits", item.count)
                )
                .symbolSize(selectedHour == item.hour ? 60 : 0)
                .foregroundStyle(by: .value("Week", weekLabel(for: item.weekIndex)))
            }

            if let hour = selectedHour {
                RuleMark(
                    x: .value("Selected Hour", hour)
                )
                .foregroundStyle(.primaryNormal.opacity(0.35))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                .zIndex(-1)
                .annotation(
                    position: .top,
                    spacing: 0,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
                    )
                ) {
                    valueSelectionPopover(selectedHour: hour)
                }
            }
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
        .chartXSelection(value: snappedHourBinding)
        .overlay {
            TimeLineEmptyState(message: .dashboardEmptyChartMessage)
                .setupFont(.bodyMedium12)
                .opacity(series.isEmpty ? 1 : 0)
        }
        .onChange(of: selectedHour) { triggerMediumHapticFeedback() }
    }
}

extension CellChartGraph {
    struct WeekVisitSummary: Identifiable {
        let weekIndex: Int
        let count: Int
        var id: Int { weekIndex }
    }

    /// 특정 시간의 주차별 count
    private func visitsPerWeek(at hour: Int) -> [WeekVisitSummary] {
        let filtered = series.filter { $0.hour == hour && $0.count > 0 }
        let grouped = Dictionary(grouping: filtered, by: { $0.weekIndex })
        return grouped.keys.sorted().map { week in
            WeekVisitSummary(
                weekIndex: week,
                count: grouped[week]?.map(\.count).reduce(0, +) ?? 0
            )
        }
    }

    @ViewBuilder
    func valueSelectionPopover(selectedHour: Int) -> some View {
        let data = visitsPerWeek(at: selectedHour)
        
        VStack(alignment: .leading) {
            Text(String(format: "%02d시 체류 패턴", selectedHour))
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 20) {
                ForEach(data) { item in
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(item.count)")
                            .font(.caption.bold())
                        
                        Text("\(item.weekIndex)주차")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(6)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.gray.opacity(0.8))
        }
    }
}
