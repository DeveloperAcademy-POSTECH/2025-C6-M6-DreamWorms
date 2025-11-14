//
//  NMGLatLngBounds+Coverage.swift
//  SUSA24-iOS
//
//  Created by GPT-5 Codex on 11/13/25.
//

import CoreLocation
import NMapsMap

extension NMGLatLngBounds {
    /// 중심 좌표와 반경(미터)로 정사각형 Bounds를 생성합니다.
    /// - Parameters:
    ///   - center: 중심 좌표
    ///   - radiusMeters: 반경(미터)
    static func coverageBounds(center: CLLocationCoordinate2D, radiusMeters: Double) -> NMGLatLngBounds {
        let earthRadius: Double = 6_378_137 // WGS84 적도 반경 (m)
        
        let latRad = center.latitude * .pi / 180
        let deltaLat = (radiusMeters / earthRadius) * 180 / .pi
        let cosLat = cos(latRad)
        let deltaLng: Double = if abs(cosLat) < 1e-6 {
            180
        } else {
            (radiusMeters / (earthRadius * cosLat)) * 180 / .pi
        }
        
        let southWest = NMGLatLng(
            lat: center.latitude - deltaLat,
            lng: center.longitude - deltaLng
        )
        let northEast = NMGLatLng(
            lat: center.latitude + deltaLat,
            lng: center.longitude + deltaLng
        )
        return NMGLatLngBounds(southWest: southWest, northEast: northEast)
    }
}
