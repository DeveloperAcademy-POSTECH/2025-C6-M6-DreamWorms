//
//  VisitDurationChart.swift
//  SUSA24-iOS
//
//  Created by mini on 11/4/25.
//

import SwiftUI
import Charts

struct VisitDurationChart: View {
    let points: [HourValue]
    
    /// 주당 포인트 수 (요일=7, 시간=24 등)
    var pointsPerWeek: Int = 7

    /// 최대 렌더링 주차
    var maxWeeks: Int = 4

    /// 주 내 인덱스 기반 하이라이트(예: 2...4)
    var highlight: ClosedRange<Int>? = nil

    // 주차별 팔레트 (필요 시 확장)
    private let weekPalette: [Color] = [
        .primaryNormal,
        .primaryLight1,
        .primaryStrong,
        .primaryLight2
    ]
    
    private var weeklySeries: [[HourValue]] {
        let limited = Array(points.prefix(pointsPerWeek * maxWeeks))
        var buckets: [[HourValue]] = Array(repeating: [], count: maxWeeks)

        for (i, p) in limited.enumerated() {
            let weekIdx = i / pointsPerWeek
            guard weekIdx < maxWeeks else { break }
            let xWithinWeek = i % pointsPerWeek
            buckets[weekIdx].append(HourValue(hour: xWithinWeek, value: p.value))
        }
        return buckets.filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(spacing: 18) {
            Chart {
                // MARK: - 중요한 부분 하이라이트 치는 부분 (일단 주석 처리해둠)

    //            if let r = highlight {
    //                RectangleMark(
    //                    xStart: .value("start", r.lowerBound),
    //                    xEnd:   .value("end",   r.upperBound+1),
    //                    yStart: .value("y0", 0),
    //                    yEnd:   .value("y1", 12)
    //                )
    //                .foregroundStyle(dark.opacity(0.15))
    //                .zIndex(-1)
    //            }
    
                // MARK: - 실제 데이터로 그래프를 그리는 부분
                ForEach(
                    Array(weeklySeries.enumerated()),
                    id: \.offset
                ) { (weekIdx, series) in
                    let label = "\(weekIdx + 1)주차"
                    ForEach(series) { p in
                        LineMark(
                            x: .value("IndexInWeek", p.hour),
                            y: .value("Value", p.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(by: .value("주차", label))
                        .symbol(by: .value("주차", label))
                        .lineStyle(.init(lineWidth: 2))
                    }
                }
                
                
            }
            .chartLegend(.hidden)
            //.chartLegend(position: .top, alignment: .trailing, spacing: 8)
            
            
            .chartYScale(domain: 0...12)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour)) { v in
                    AxisGridLine().foregroundStyle(.black.opacity(0.08))
                    AxisTick().foregroundStyle(.black.opacity(0.15))
                    AxisValueLabel(format: .dateTime.day())
                        .foregroundStyle(.labelAssistive)
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(.labelAssistive)
                    AxisTick().foregroundStyle(.clear)
                    AxisValueLabel().foregroundStyle(.clear)
                }
            }
            .frame(height: 142)
            .padding(.top, 8)
            .padding(.trailing, 8)
            
            
            
            
            
            
            WeekdayPillPicker(selection: .constant(.mon))
        }

    }
}


#Preview {
    let total = 21
    let sample: [HourValue] = Array(0..<total).map { idx in
        HourValue(hour: idx, value: Double.random(in: 1...10))
    }

    VisitDurationChart(
        points: sample,
        highlight: 2...4
    )
    .padding()
    .background(Color(.systemBackground))
}
