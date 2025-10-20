//
//  NaverMapDisplayMode.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation

public enum NaverMapDisplayMode: String, CaseIterable, Sendable {
    case uniqueLocations = "unique" // 기본
    case frequency // 빈도 표시
    case timeSequence = "sequence" // 시간순 그룹화
    case flow // 화살표 흐름 표시
    
    public var title: String {
        switch self {
        case .uniqueLocations:
            "기본 위치"
        case .frequency:
            "빈도 표시"
        case .timeSequence:
            "시간순 그룹"
        case .flow:
            "이동 경로"
        }
    }
}
