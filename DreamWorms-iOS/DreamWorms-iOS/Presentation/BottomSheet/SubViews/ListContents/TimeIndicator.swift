//
//  TimeIndicator.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 시간 인디케이터
///
/// 역할: 시계 아이콘 + 시간 범위만
struct TimeIndicator: View {
    let startTime: Date
    let endTime: Date
    
    var body: some View {
        IndicatorRow(
            startTime: startTime,
            endTime: endTime
        )
    }
}

// MARK: - Indicator Row

/// 인디케이터 행
///
/// 역할: 아이콘 + 텍스트 조합만
private struct IndicatorRow: View {
    let startTime: Date
    let endTime: Date
    
    var body: some View {
        HStack(spacing: 4) {
            ClockIcon()
            TimeRangeText(startTime: startTime, endTime: endTime)
        }
    }
}

// MARK: - Clock Icon

/// 시계 아이콘
///
/// 역할: 아이콘만
private struct ClockIcon: View {
    var body: some View {
        Image(systemName: "clock")
            .font(.system(size: 12))
            .foregroundStyle(Color.gray8B)
    }
}

// MARK: - Time Range Text

/// 시간 범위 텍스트
///
/// 역할: 시간 포맷팅 + 표시만
private struct TimeRangeText: View {
    let startTime: Date
    let endTime: Date
    
    var body: some View {
        Text("\(formattedTime(startTime)) - \(formattedTime(endTime))")
            .font(.pretendardRegular(size: 13))
            .foregroundStyle(Color.gray8B)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 10) {
        TimeIndicator(
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600)
        )
        
        TimeIndicator(
            startTime: Date().addingTimeInterval(-7200),
            endTime: Date().addingTimeInterval(-3600)
        )
    }
    .padding()
}
