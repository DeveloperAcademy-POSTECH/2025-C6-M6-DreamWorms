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
