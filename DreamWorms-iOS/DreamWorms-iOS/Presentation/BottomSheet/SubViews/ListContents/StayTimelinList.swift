//  StayTimelinList.swift

import SwiftUI

/// 체류 타임라인 리스트
///
/// 역할: 체류 아이템 나열
struct StayTimelineList: View {
    let stays: [LocationStay]
    
    var body: some View {
        ItemsStack(stays: stays)
    }
}

// MARK: - Items Stack

private struct ItemsStack: View {
    let stays: [LocationStay]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(stays.enumerated()), id: \.element.id) { index, stay in
                StayTimelineItem(
                    stay: stay,
                    isLast: index == stays.count - 1
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StayTimelineList(stays: [])
        .padding()
}
