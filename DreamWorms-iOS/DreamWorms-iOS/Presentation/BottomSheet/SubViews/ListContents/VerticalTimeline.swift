//
//  VerticalTimeline.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 세로 타임라인
///
/// 역할: 점 + 세로선만
struct VerticalTimeline: View {
    let isLast: Bool
    
    var body: some View {
        TimelineColumn(isLast: isLast)
    }
}

// MARK: - Timeline Column

/// 타임라인 세로 열
///
/// 역할: 점 + 선 조합만
private struct TimelineColumn: View {
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TimelineDot()
            
            if !isLast { // ✅ 마지막이 아니면 선 표시
                TimelineLine()
            }
        }
        .frame(width: 8)
    }
}

// MARK: - Timeline Dot

/// 타임라인 점
///
/// 역할: 점 UI만
private struct TimelineDot: View {
    var body: some View {
        Circle()
            .fill(Color.mainBlue)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Timeline Line

/// 타임라인 세로선
///
/// 역할: 선 UI만
private struct TimelineLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.grayD9)
            .frame(width: 2)
            .padding(.top, 4)
    }
}

// MARK: - Preview

#Preview("Not Last") {
    VStack(spacing: 20) {
        HStack(alignment: .top) {
            VerticalTimeline(isLast: false)
            Text("컨텐츠 영역\n여러 줄\n테스트")
        }
    }
    .padding()
}

#Preview("Last Item") {
    VStack(spacing: 20) {
        HStack(alignment: .top) {
            VerticalTimeline(isLast: false)
            Text("첫 번째")
        }
        
        HStack(alignment: .top) {
            VerticalTimeline(isLast: false)
            Text("두 번째")
        }
        
        HStack(alignment: .top) {
            VerticalTimeline(isLast: true) // ✅ 마지막 - 선 없음
            Text("마지막")
        }
    }
    .padding()
}
