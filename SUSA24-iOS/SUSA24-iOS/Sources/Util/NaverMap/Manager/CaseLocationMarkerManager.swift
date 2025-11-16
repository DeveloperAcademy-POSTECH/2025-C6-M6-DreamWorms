//
//  CaseLocationMarkerManager.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
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
    /// - Returns: 좌표 키와 방문 횟수 매핑 (셀 타입에 한함)
    @discardableResult
    func updateMarkers(
        _ locations: [Location],
        on mapView: NMFMapView
    ) -> [String: Int] {
        // TAENI : 테스트를 위한 로그 추가
        // 전체 로케이션을 다 직어보고 싶으면 세번째 주석 처리 된 로그를 풀면 다 나옴.
        print("🟡 [MarkerManager] updateMarkers called")
        print("🟡 [MarkerManager] locations.count: \(locations.count)")
//        print("🟡 [MarkerManager] locations: \(locations.map { "[\($0.id)] \($0.address)" })")
        
        let (markers, cellCounts) = buildMarkers(from: locations)
        
        print("🟡 [MarkerManager] markers built: \(markers.count)")
        
        applyMarkers(markers, on: mapView)
        
        print("🟡 [MarkerManager] markers applied to map")
        
        return cellCounts
    }

    /// 모든 마커를 제거합니다.
    func clearAll() {
        for marker in markers.values {
            marker.mapView = nil
        }
        markers.removeAll()
        markerTypes.removeAll()
    }
    
    /// 방문 빈도 배지를 셀 마커에 적용합니다.
    /// - Parameters:
    ///   - cellCounts: 좌표 키와 방문 횟수 매핑
    ///   - mapView: 네이버 지도 뷰
    func applyVisitFrequency(with cellCounts: [String: Int], on mapView: NMFMapView) {
        guard !cellCounts.isEmpty else { return }

        Task {
            for (id, count) in cellCounts {
                guard let overlay = self.markers[id] else { continue }
                let icon = await MarkerImageCache.shared.image(for: .cellWithCount(count: count))
                overlay.iconImage = NMFOverlayImage(image: icon)
                overlay.hidden = false
                overlay.mapView = mapView
                markerTypes[id] = .cellWithCount(count: count)
            }
        }
    }

    /// 방문 빈도 배지를 기본 상태로 복원합니다.
    /// - Parameter mapView: 네이버 지도 뷰
    func resetVisitFrequency(on mapView: NMFMapView) {
        Task {
            for (id, overlay) in markers {
                guard case .cellWithCount = markerTypes[id] else { continue }
                let icon = await MarkerImageCache.shared.image(for: .cell(isVisited: true))
                overlay.iconImage = NMFOverlayImage(image: icon)
                overlay.hidden = false
                overlay.mapView = mapView
                markerTypes[id] = .cell(isVisited: true)
            }
        }
    }

    /// 모든 케이스 위치 마커의 표시/숨김을 전환합니다.
    /// - Parameter isVisible: true면 표시, false면 숨김
    func setVisibility(_ isVisible: Bool) {
        for marker in markers.values {
            marker.hidden = !isVisible
        }
    }
    
    private struct MarkerModel {
        let id: String
        let coordinate: MapCoordinate
        
        var markerType: MarkerType
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

    /// Location 배열을 마커 모델과 셀 좌표 카운트로 변환합니다.
    private func buildMarkers(from locations: [Location]) -> ([MarkerModel], [String: Int]) {
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

        let cellCounts = cellGroups.mapValues(\.count)
        return (markers, cellCounts)
    }

    /// Location으로부터 생성된 마커를 지도에 적용합니다.
    /// - Parameters:
    ///   - markerModels: 생성한 마커 모델 배열
    ///   - mapView: 갱신할 네이버 지도 뷰
    private func applyMarkers(_ markerModels: [MarkerModel], on mapView: NMFMapView) {
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

    private func coordinateKey(latitude: Double, longitude: Double) -> String {
        let latString = String(format: "%.6f", latitude)
        let lngString = String(format: "%.6f", longitude)
        return "\(latString)_\(lngString)"
    }

    private func desiredMarkerType(
        for markerInfo: MarkerModel,
        visitFrequencyEnabled: Bool,
        cellCounts: [String: Int]
    ) -> MarkerType {
        switch markerInfo.markerType {
        case .cell:
            if visitFrequencyEnabled {
                let count = cellCounts[markerInfo.id] ?? 1
                return .cellWithCount(count: count)
            } else {
                return .cell(isVisited: true)
            }
        default:
            return markerInfo.markerType
        }
    }

    /// 셀 마커의 방문 횟수를 정수로 반환합니다.
    /// - Parameters:
    ///   - markerInfo: 평가할 마커 모델 정보
    ///   - cellCounts: 좌표 키와 방문 횟수 매핑
    /// - Returns: 방문 횟수 (디폴트는 1)
    private func cellVisitCount(for markerInfo: MarkerModel, cellCounts: [String: Int]) -> Int {
        cellCounts[markerInfo.id] ?? 1
    }
}
