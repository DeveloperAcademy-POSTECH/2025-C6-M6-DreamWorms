//
//  TimelineContent.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 타임라인 컨텐츠
///
/// 역할: 위치 + 시간 조합만
struct TimelineContent: View {
    let location: String
    let startTime: Date
    let endTime: Date
    
    var body: some View {
        ContentStack(
            location: location,
            startTime: startTime,
            endTime: endTime
        )
    }
}

// MARK: - Content Stack

/// 컨텐츠 스택
///
/// 역할: 위치 + 시간 세로 배치만
private struct ContentStack: View {
    let location: String
    let startTime: Date
    let endTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            LocationText(location: location)
            TimeIndicator(startTime: startTime, endTime: endTime)
        }
    }
}

// MARK: - Location Text

/// 위치 텍스트
///
/// 역할: 위치 표시만
private struct LocationText: View {
    let location: String
    
    var body: some View {
        Text(location)
            .font(.pretendardMedium(size: 15))
            .foregroundStyle(Color.black22)
    }
}

// MARK: - Preview

#Preview {
    TimelineContent(
        location: "부산 강서구 지사동",
        startTime: Date(),
        endTime: Date().addingTimeInterval(3600)
    )
    .padding()
}
