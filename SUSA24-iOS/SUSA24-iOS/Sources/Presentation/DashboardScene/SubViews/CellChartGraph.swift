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
    
    /// 시간별 총 방문 수(모든 주차 합산). 최신 주만 쓰고 싶다면 아래 합산 대상 필터를 변경하세요.
    private var totalByHour: [Int: Int] {
        let base = series
        return base.reduce(into: [Int: Int]()) { dict, item in
            dict[item.hour, default: 0] += item.count
        }
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
            if let band = bestHighBand() {
                RectangleMark(
                    xStart: .value("from", band.lowerBound),
                    xEnd: .value("to", band.upperBound + 1),
                    yStart: .value("min", 0),
                    yEnd: .value("max", 11)
                )
                .foregroundStyle(.primaryNormal.opacity(0.15))
                .zIndex(-2)
            }
            
            ForEach(series, id: \.id) { item in
                LineMark(
                    x: .value("Hour", item.hour),
                    y: .value("Visits", item.count),
                    series: .value("Week", weekLabel(for: item.weekIndex))
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)
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
                .foregroundStyle(.labelCoolNormal)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                .zIndex(-1)
                .annotation(
                    position: .top,
                    spacing: 0,
                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
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

    @ViewBuilder
    func valueSelectionPopover(selectedHour: Int) -> some View {
        let data = visitsPerWeek(at: selectedHour)
        
        VStack(alignment: .leading, spacing: 0) {
            Text(String(format: "%02d시 체류 패턴", selectedHour))
                .font(.bodyMedium10)
                .foregroundStyle(.labelAlternative)
                .padding(.bottom, 2)
            
            HStack(spacing: 12) {
                ForEach(data) { item in
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(item.count)")
                            .font(.numberSemiBold18)
                            .foregroundStyle(colorForWeek(item.weekIndex))
                        
                        Text("\(item.weekIndex)주차")
                            .font(.bodyMedium10)
                            .foregroundStyle(.labelNormal.opacity(0.3))
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(.labelCoolNormal)
        }
    }
}

private extension CellChartGraph {
    /// 주차 인덱스를 weekStyleScale의 키("n주차")로 매핑해 Color 반환
    func colorForWeek(_ weekIndex: Int) -> Color {
        let key = weekLabel(for: weekIndex)
        return weekStyleScale.first(where: { $0.key == key })?.value ?? .primaryNormal
    }
    
    /// 특정 시간의 주차별 count
    func visitsPerWeek(at hour: Int) -> [WeekVisitSummary] {
        // 전체 주차 범위 계산 (데이터가 없으면 1주차만)
        let allWeeks = Array(1 ... (series.map(\.weekIndex).max() ?? 1))

        // 주차별 방문 데이터 그룹화
        let grouped = Dictionary(
            grouping: series.filter { $0.hour == hour },
            by: { $0.weekIndex }
        )

        // 모든 주차를 순회하며 0인 주차도 포함
        return allWeeks.map { week in
            let total = grouped[week]?.map(\.count).reduce(0, +) ?? 0
            return WeekVisitSummary(weekIndex: week, count: total)
        }
    }
    
    /// 시간대 총합을 이동평균으로 부드럽게 만듭니다.
    /// - Parameter window: 이동평균 창 크기(기본 3)
    func smoothedTotals(window: Int = 3) -> [Int: Double] {
        let hours = 0 ... 23
        let rangeSize = max(1, window)
        let halfRange = rangeSize / 2
        var smoothedValues: [Int: Double] = [:]

        for hour in hours {
            let startHour = hour - halfRange
            let endHour = hour + halfRange

            var totalCount = 0
            var sampleCount = 0

            for sample in startHour ... endHour {
                let wrappedHour = (sample % 24 + 24) % 24
                totalCount += totalByHour[wrappedHour] ?? 0
                sampleCount += 1
            }

            smoothedValues[hour] = sampleCount > 0 ? Double(totalCount) / Double(sampleCount) : 0
        }

        return smoothedValues
    }

    /// 스무딩된 값에서 (최대값 * threshold) 이상인 연속 구간 중 가장 긴 구간을 반환합니다.
    /// 없으면 최대값 하나의 시간 칸을 반환하고, 값이 전부 0이면 nil을 반환합니다.
    func bestHighBand(threshold: Double = 0.8, window: Int = 3) -> ClosedRange<Int>? {
        let smoothed = smoothedTotals(window: window)
        guard let peakValue = smoothed.values.max(), peakValue > 0 else { return nil }

        let cutoffValue = peakValue * threshold

        var bestRange: (start: Int, end: Int)? = nil
        var currentRangeStart: Int? = nil

        for hour in 0 ... 24 {
            let value = (hour <= 23) ? (smoothed[hour] ?? 0) : 0

            if value >= cutoffValue {
                if currentRangeStart == nil {
                    currentRangeStart = hour
                }
            } else if let rangeStart = currentRangeStart {
                let rangeEnd = min(hour - 1, 23)
                if bestRange == nil || (rangeEnd - rangeStart) > (bestRange!.end - bestRange!.start) {
                    bestRange = (rangeStart, rangeEnd)
                }
                currentRangeStart = nil
            }
        }

        if let best = bestRange {
            return best.start ... best.end
        }

        if let peakHour = (0 ... 23).max(by: { (smoothed[$0] ?? 0) < (smoothed[$1] ?? 0) }) {
            return peakHour ... peakHour
        }
        
        return nil
    }
    
    /// 주차 Index를 받아 String "n주차"의 형태로 반환하는 메서드입니다.
    func weekLabel(for weekIndex: Int) -> String { "\(weekIndex)주차" }
}
