//
//  MapCoordinate.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/8/25.
//

import Foundation

/// 지도 명령을 전달하기 위한 좌표 값입니다.
/// `NMFMapView`가 사용하는 위도/경도 순서를 그대로 보존해 명령 디스패처가
/// 다른 모듈과 안전하게 좌표 정보를 교환할 수 있도록 돕습니다.
struct MapCoordinate: Equatable, Sendable, Hashable {
    /// 이동 대상 위치의 위도입니다.
    let latitude: Double
    /// 이동 대상 위치의 경도입니다.
    let longitude: Double
}

// MARK: - Coordinate Key

extension MapCoordinate {
    /// 좌표를 셀 좌표 키로 변환합니다. (소수점 6자리 위도/경도 조합)
    var coordinateKey: String {
        let latString = String(format: "%.6f", latitude)
        let lngString = String(format: "%.6f", longitude)
        return "\(latString)_\(lngString)"
    }
}
