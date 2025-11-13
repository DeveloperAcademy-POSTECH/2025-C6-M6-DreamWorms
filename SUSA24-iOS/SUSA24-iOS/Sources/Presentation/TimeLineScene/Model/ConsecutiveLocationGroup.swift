//
//  ConsecutiveLocationGroup.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/12/25.
//

// MARK: - 연속 위치 그룹 모델

/// 같은 주소에 연속으로 머문 위치들의 그룹
///
/// ## 플로우
/// ```
/// 부산시 해운대구 2:30pm 수신
/// 부산시 해운대구 2:40pm 수신
///  -> start 2:30pm end 2:40pm
///  ```

import Foundation
import SwiftUI

struct ConsecutiveLocationGroup: Identifiable, Sendable, Hashable {
    let id: UUID
    let address: String
    let locations: [Location]
    let startTime: Date
    let endTime: Date?
    let state: TimeLineColorStickState

    /// 방문횟수
    var visitCount: Int {
        locations.count
    }

    /// 마지막 시간과 시작 시간 격차
    var stayDuration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    // MARK: - initalization

    init(
        address: String,
        locations: [Location],
        state: TimeLineColorStickState,
        startTime: Date,
        endTime: Date?
    ) {
        self.id = UUID()
        self.address = address
        self.locations = locations
        self.state = state
        self.startTime = startTime
        self.endTime = endTime
    }
}
