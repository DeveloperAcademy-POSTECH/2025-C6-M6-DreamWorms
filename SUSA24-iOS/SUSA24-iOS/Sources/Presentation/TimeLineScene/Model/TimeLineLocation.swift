//
//  TimeLineLocation.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import Foundation

// MARK: - TimeLineLocation (타임라인 전용 모델)

/// 타임라인에서 표시할 위치 정보
/// - Location 모델에서 필요한 것만 추출하여 변환
/// - 최근에 연속된 같은 위치는 하나로 합쳐짐 ( 시간은 더해짐 )
struct TimeLineLocation: Identifiable, Equatable, Sendable {
    let id = UUID()
    let adderess: String
    let caseTitle
}
