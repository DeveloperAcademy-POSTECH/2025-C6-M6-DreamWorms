//
//  CaseLocationMarkerManager.swift
//  SUSA24-iOS
//
//  Created by Assistant on 11/13/25.
//

import Foundation
import NMapsGeometry
import NMapsMap

/// 케이스별 위치 마커를 관리하는 매니저
@MainActor
final class CaseLocationMarkerManager {
    // MARK: - Properties
    
    /// 용의자 위치 마커 저장소 (markerId -> NMFMarker)
    private var markers: [String: NMFMarker] = [:]
    /// 마커 타입 캐시 (markerId -> MarkerType)
    private var markerTypes: [String: MarkerType] = [:]
    
    // MARK: - Public Methods
    
    /// 케이스 위치 마커를 업데이트합니다.
    /// - Parameters:
    ///   - locations: 표시할 위치 데이터 배열
    ///   - mapView: 네이버 지도 뷰
    func updateMarkers(
        _ locations: [Location],
        on mapView: NMFMapView
    ) {
        let markerModels = buildMarkers(from: locations)
        let currentIds = Set(markerModels.map(\.id))
        let existingIds = Set(markers.keys)
        
        let idsToRemove = existingIds.subtracting(currentIds)
        
        for markerId in idsToRemove {
            markers[markerId]?.mapView = nil
            markers.removeValue(forKey: markerId)
            markerTypes.removeValue(forKey: markerId)
        }
        
        Task {
            for markerInfo in markerModels {
                if let overlay = self.markers[markerInfo.id] {
                    overlay.position = NMGLatLng(
                        lat: markerInfo.coordinate.latitude,
                        lng: markerInfo.coordinate.longitude
                    )
                    if overlay.mapView == nil {
                        overlay.mapView = mapView
                    }
                    if markerTypes[markerInfo.id] != markerInfo.markerType {
                        let icon = await MarkerImageCache.shared.image(for: markerInfo.markerType)
                        overlay.iconImage = NMFOverlayImage(image: icon)
                        markerTypes[markerInfo.id] = markerInfo.markerType
                    }
                    overlay.hidden = false
                } else {
                    let overlay = await self.createMarker(
                        for: markerInfo,
                        on: mapView
                    )
                    self.markers[markerInfo.id] = overlay
                    self.markerTypes[markerInfo.id] = markerInfo.markerType
                }
            }
        }
    }
    
    /// 모든 마커를 제거합니다.
    func clearAll() {
        for marker in markers.values {
            marker.mapView = nil
        }
        markers.removeAll()
        markerTypes.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func createMarker(
        for marker: MarkerModel,
        on mapView: NMFMapView
    ) async -> NMFMarker {
        let overlay = NMFMarker()
        overlay.position = NMGLatLng(
            lat: marker.coordinate.latitude,
            lng: marker.coordinate.longitude
        )
        let icon = await MarkerImageCache.shared.image(for: marker.markerType)
        overlay.iconImage = NMFOverlayImage(image: icon)
        overlay.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        overlay.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        overlay.hidden = false
        overlay.mapView = mapView
        return overlay
    }

    private struct MarkerModel {
        let id: String
        let coordinate: MapCoordinate
        let markerType: MarkerType
    }

    private func buildMarkers(from locations: [Location]) -> [MarkerModel] {
        var markers: [MarkerModel] = []
        var cellGroups: [String: (coordinate: MapCoordinate, count: Int)] = [:]

        for location in locations {
            let latitude = location.pointLatitude
            let longitude = location.pointLongitude
            guard latitude != 0, longitude != 0 else { continue }

            let coordinate = MapCoordinate(latitude: latitude, longitude: longitude)

            switch LocationType(location.locationType) {
            case .home:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    markerType: .home
                ))

            case .work:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    markerType: .work
                ))

            case .custom:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    markerType: .custom
                ))

            case .cell:
                let key = coordinateKey(latitude: latitude, longitude: longitude)
                var entry = cellGroups[key] ?? (coordinate, 0)
                entry.count += 1
                cellGroups[key] = entry
            }
        }

        for (key, entry) in cellGroups {
            markers.append(
                MarkerModel(
                    id: key,
                    coordinate: entry.coordinate,
                    markerType: .cell(isVisited: true)
                )
            )
        }

        return markers
    }

    private func coordinateKey(latitude: Double, longitude: Double) -> String {
        let latString = String(format: "%.6f", latitude)
        let lngString = String(format: "%.6f", longitude)
        return "\(latString)_\(lngString)"
    }
}
