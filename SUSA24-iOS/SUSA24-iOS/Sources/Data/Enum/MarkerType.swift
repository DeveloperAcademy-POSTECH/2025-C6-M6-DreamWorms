//
//  MarkerType.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/12/25.
//

// MARK: - MarkerType

/// 마커의 타입을 정의하는 열거형
enum MarkerType: Equatable, Hashable, Sendable {
    case home
    case work
    case cell(isVisited: Bool)
    case cellWithCount(count: Int) // 방문횟수 표시
    case cctv
    case custom
}

// MARK: - Layer Classification

extension MarkerType {
    /// 인프라 레이어 (Cell + CCTV)에 해당하는지 확인
    var isInfrastructure: Bool {
        switch self {
        case .cell, .cellWithCount, .cctv:
            true
        default:
            false
        }
    }
    
    /// 사용자 위치 레이어 (Home, Work, Custom)에 해당하는지 확인
    var isUserLocation: Bool {
        switch self {
        case .home, .work, .custom:
            true
        default:
            false
        }
    }
}

// MARK: - Cache Key

extension MarkerType {
    /// 캐시 키로 사용할 고유 문자열 식별자
    /// - Main actor와 분리하기 위해 nonisolated로 표시
    nonisolated var cacheKey: String {
        switch self {
        case .home:
            "home"
        case .work:
            "work"
        case let .cell(isVisited):
            "cell_\(isVisited)"
        case let .cellWithCount(count):
            "cellWithCount_\(count)"
        case .cctv:
            "cctv"
        case .custom:
            "custom"
        }
    }
}
