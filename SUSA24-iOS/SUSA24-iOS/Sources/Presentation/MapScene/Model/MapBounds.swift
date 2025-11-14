//
//  MapBounds.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

struct MapBounds: Equatable, Sendable {
    let minLongitude: Double
    let minLatitude: Double
    let maxLongitude: Double
    let maxLatitude: Double
}

extension MapBounds {
    /// 두 범위를 합친 최소 사각형을 반환합니다.
    func union(_ other: MapBounds) -> MapBounds {
        MapBounds(
            minLongitude: min(minLongitude, other.minLongitude),
            minLatitude: min(minLatitude, other.minLatitude),
            maxLongitude: max(maxLongitude, other.maxLongitude),
            maxLatitude: max(maxLatitude, other.maxLatitude)
        )
    }
    
    /// 두 범위가 겹치는지 여부를 반환합니다.
    func intersects(_ other: MapBounds) -> Bool {
        !(other.minLongitude > maxLongitude ||
            other.maxLongitude < minLongitude ||
            other.minLatitude > maxLatitude ||
            other.maxLatitude < minLatitude)
    }
    
    /// 다른 범위가 현재 범위 안에 완전히 포함되는지 여부를 반환합니다.
    func contains(_ other: MapBounds) -> Bool {
        other.minLongitude >= minLongitude &&
            other.maxLongitude <= maxLongitude &&
            other.minLatitude >= minLatitude &&
            other.maxLatitude <= maxLatitude
    }
}
