//
//  MapDataService.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/25/25.
//

import Foundation

/// 맵 데이터 변환 및 조회를 담당하는 서비스
enum MapDataService {
    // MARK: - Data Transformation
    
    /// 방문 데이터에서 셀 위치만 추출해 기지국 마커 스냅샷으로 변환합니다.
    /// - Parameter locations: 위치 데이터 배열
    /// - Returns: 변환된 CellMarker 배열
    static func makeVisitedCellMarkers(from locations: [Location]) -> [CellMarker] {
        let cellGroups = locations.visitFrequencyByCoordinate()
        return cellGroups
            .sorted { $0.key < $1.key }
            .map { key, value in
                CellMarker(
                    permitNumber: 0,
                    location: key,
                    purpose: "",
                    latitude: value.latitude,
                    longitude: value.longitude,
                    visitCount: value.count
                )
            }
    }
    
    // MARK: - Data Lookup
    
    /// 좌표 키에 해당하는 기지국 셀의 주소(CellMarker.location)를 반환합니다.
    /// - Parameters:
    ///   - cellKey: 좌표 키 (위도_경도 형식)
    ///   - cellStations: 검색할 CellMarker 배열
    /// - Returns: 매칭되는 CellMarker의 location (없으면 nil)
    static func findCellTitle(by cellKey: String, in cellStations: [CellMarker]) -> String? {
        for marker in cellStations {
            let key = MapCoordinate(latitude: marker.latitude, longitude: marker.longitude).coordinateKey
            if key == cellKey { return marker.location }
        }
        return nil
    }
    
    // MARK: - Hash Calculation
    
    /// Location 배열의 해시 값을 계산합니다.
    /// - Parameters:
    ///   - locations: 해시를 계산할 Location 배열
    ///   - visitFrequencyEnabled: 방문 빈도 활성화 여부
    /// - Returns: 계산된 해시 값
    static func hash(for locations: [Location], visitFrequencyEnabled: Bool) -> Int {
        var hasher = Hasher()
        for location in locations {
            hasher.combine(location.id)
            hasher.combine(location.locationType)
            hasher.combine(location.pointLatitude)
            hasher.combine(location.pointLongitude)
            hasher.combine(location.colorType)
        }
        hasher.combine(visitFrequencyEnabled)
        return hasher.finalize()
    }
    
    /// CellMarker 배열의 해시 값을 계산합니다.
    /// - Parameter cellMarkers: 해시를 계산할 CellMarker 배열
    /// - Returns: 계산된 해시 값
    static func hash(for cellMarkers: [CellMarker]) -> Int {
        var hasher = Hasher()
        for marker in cellMarkers.sorted(by: { $0.id < $1.id }) {
            hasher.combine(marker.id)
            hasher.combine(marker.visitCount)
        }
        return hasher.finalize()
    }
}
