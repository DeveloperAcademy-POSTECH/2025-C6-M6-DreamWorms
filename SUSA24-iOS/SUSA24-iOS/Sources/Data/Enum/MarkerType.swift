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

// MARK: - Z-Index

extension MarkerType {
    /// 마커의 Z-Index 값을 반환합니다.
    /// 값이 클수록 위에 표시됩니다.
    ///
    /// 우선순위: home (100) > work (90) > custom (80) > cellWithCount (70)
    /// > cell(isVisited: true) (60) > CCTV (50) > cell(isVisited: false) (10)
    var zIndex: Int {
        switch self {
        case .home: 100
        case .work: 90
        case .custom: 80
        case .cellWithCount: 70
        case let .cell(isVisited): isVisited ? 60 : 10 // 방문한 기지국: 60, 방문 안 한 기지국: 10
        case .cctv: 50
        }
    }
}

// MARK: - Collision Handling Strategy

extension MarkerType {
    /// 마커와 지도 심벌이 겹칠 때 심벌을 숨길지 여부
    var shouldHideCollidedSymbols: Bool {
        true // 모든 마커에서 지도 심벌 숨김
    }
    
    /// 마커가 다른 마커와 겹칠 때 겹치는 마커를 숨길지 여부
    ///
    /// **중요**: 사용자 위치 마커는 false로 설정하여 기지국 마커도 탭 가능하도록 합니다.
    var shouldHideCollidedMarkers: Bool {
        switch self {
        case .home, .work, .custom:
            false // 사용자 위치 마커: 다른 마커를 숨기지 않음 (기지국 마커도 탭 가능)
        case .cell, .cellWithCount, .cctv:
            true // 인프라 마커: 겹침 처리 활성화
        }
    }
    
    /// 마커가 다른 마커와 겹칠 때 강제로 표시할지 여부
    /// (isHideCollidedMarkers가 true인 다른 마커와 겹치더라도 표시)
    var shouldForceShowIcon: Bool {
        switch self {
        case .home, .work, .custom:
            false // 사용자 위치 마커: 겹칠 수 있음 (기지국 마커와 함께 표시)
        case .cell, .cellWithCount, .cctv:
            false // 인프라 마커: 겹치면 숨김 가능
        }
    }
    
    /// 마커가 다른 마커와 겹칠 때 캡션만 숨길지 여부
    /// (isHideCollidedMarkers가 true인 경우 무시됨)
    var shouldHideCollidedCaptions: Bool {
        switch self {
        case .home, .work, .custom:
            false // 사용자 위치 마커: 캡션은 항상 표시 시도
        case .cell, .cellWithCount, .cctv:
            true // 인프라 마커: 캡션 없음
        }
    }
}

// MARK: - SelectedPinStyle Conversion

extension MarkerType {
    /// MarkerType을 SelectedPinStyle로 변환합니다.
    /// - 작은 마커에서 선택된 큰 핀으로 변환할 때 사용합니다.
    /// - Parameters:
    ///   - pinColor: 핀 색상 (기본값: .black)
    /// - Returns: 변환된 SelectedPinStyle (선택 불가능한 마커는 nil 반환)
    func toSelectedPinStyle(pinColor: PinColorType = .black) -> SelectedPinStyle? {
        switch self {
        case .home:
            .home(pinColor)
        case .work:
            .work(pinColor)
        case .custom:
            .custom(pinColor)
        case .cell:
            // 셀은 고정 색상 사용
            .cell(.black)
        case .cellWithCount, .cctv:
            // 선택 불가능한 마커는 nil 반환
            nil
        }
    }
}
