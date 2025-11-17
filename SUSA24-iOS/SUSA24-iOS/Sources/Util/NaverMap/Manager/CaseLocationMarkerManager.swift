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
        on mapView: NMFMapView,
        onCellTapped: @escaping (String) -> Void
    ) async -> [String: Int] {
        let (markers, cellCounts) = buildMarkers(from: locations)
        await applyMarkers(markers, on: mapView, onCellTapped: onCellTapped)
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
    func applyVisitFrequency(with cellCounts: [String: Int], on mapView: NMFMapView) async {
        guard !cellCounts.isEmpty else { return }
        
        for (id, count) in cellCounts {
            guard let overlay = markers[id] else { continue }
            let icon = await MarkerImageCache.shared.image(for: .cellWithCount(count: count))
            overlay.iconImage = NMFOverlayImage(image: icon)
            overlay.mapView = mapView
            markerTypes[id] = .cellWithCount(count: count)
        }
    }
    
    /// 방문 빈도 배지를 기본 상태로 복원합니다.
    /// - Parameter mapView: 네이버 지도 뷰
    func resetVisitFrequency(on mapView: NMFMapView) async {
        for (id, overlay) in markers {
            guard case .cellWithCount = markerTypes[id] else { continue }
            let icon = await MarkerImageCache.shared.image(for: .cell(isVisited: true))
            overlay.iconImage = NMFOverlayImage(image: icon)
            overlay.mapView = mapView
            markerTypes[id] = .cell(isVisited: true)
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
        /// 사용자 위치 마커의 색상 (home / work / custom 에서만 사용)
        let pinColor: PinColorType?
        
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
        let icon: UIImage = if marker.markerType.isUserLocation, let color = marker.pinColor {
            await MarkerImageCache.shared.userLocationImage(for: marker.markerType, color: color)
        } else {
            await MarkerImageCache.shared.image(for: marker.markerType)
        }
        overlay.iconImage = NMFOverlayImage(image: icon)
        overlay.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        overlay.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        overlay.mapView = mapView
        return overlay
    }
    
    /// Location 배열을 마커 모델과 셀 좌표 카운트로 변환합니다.
    private func buildMarkers(from locations: [Location]) -> ([MarkerModel], [String: Int]) {
        var markers: [MarkerModel] = []
        
        // 1. 기지국 외 마커 처리 (home, work, custom)
        for location in locations {
            let latitude = location.pointLatitude
            let longitude = location.pointLongitude
            guard latitude != 0, longitude != 0 else { continue }
            
            let coordinate = MapCoordinate(latitude: latitude, longitude: longitude)
            let pinColor = PinColorType(location.colorType)
            
            switch LocationType(location.locationType) {
            case .home:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    pinColor: pinColor,
                    markerType: .home
                ))
            case .work:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    pinColor: pinColor,
                    markerType: .work
                ))
            case .custom:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    pinColor: pinColor,
                    markerType: .custom
                ))
            case .cell:
                break
            }
        }
        
        // 2. 기지국 방문 빈도 계산 (유틸리티 사용)
        // TAENI : 계산로직을 visitFrequencyByCoordinate 에서 처리
        let cellGroups = locations.visitFrequencyByCoordinate()
        
        // 3. 기지국 마커 생성
        for (key, entry) in cellGroups {
            let coordinate = MapCoordinate(latitude: entry.latitude, longitude: entry.longitude)
            markers.append(
                MarkerModel(
                    id: key,
                    coordinate: coordinate,
                    pinColor: nil,
                    markerType: .cell(isVisited: true)
                )
            )
        }
        
        // 4. count만 추출
        let cellCounts = cellGroups.mapValues(\.count)
        return (markers, cellCounts)
    }
    
    /// Location으로부터 생성된 마커를 지도에 적용합니다.
    /// - Parameters:
    ///   - markerModels: 생성한 마커 모델 배열
    ///   - mapView: 갱신할 네이버 지도 뷰
    ///   - onCellTapped: 셀 타입 마커 탭 이벤트 콜백 (id == coordinateKey)
    private func applyMarkers(
        _ markerModels: [MarkerModel],
        on mapView: NMFMapView,
        onCellTapped: @escaping (String) -> Void
    ) async {
        let currentIds = Set(markerModels.map(\.id))
        let existingIds = Set(markers.keys)
        let idsToRemove = existingIds.subtracting(currentIds)
        
        for markerId in idsToRemove {
            markers[markerId]?.mapView = nil
            markers.removeValue(forKey: markerId)
            markerTypes.removeValue(forKey: markerId)
        }
        
        for markerInfo in markerModels {
            if let overlay = markers[markerInfo.id] {
                overlay.position = NMGLatLng(
                    lat: markerInfo.coordinate.latitude,
                    lng: markerInfo.coordinate.longitude
                )
                if overlay.mapView == nil {
                    overlay.mapView = mapView
                }
                
                // 사용자 위치 마커(home / work / custom)는 색(pinColor)이 변경될 수 있으므로
                // 타입이 같아도 항상 아이콘을 갱신한다.
                // 셀 / CCTV 등 인프라 마커는 타입이 바뀐 경우에만 갱신한다.
                let isUserLocation = markerInfo.markerType.isUserLocation
                let typeChanged = markerTypes[markerInfo.id] != markerInfo.markerType
                
                if isUserLocation || typeChanged {
                    let icon: UIImage = if isUserLocation, let color = markerInfo.pinColor {
                        await MarkerImageCache.shared.userLocationImage(for: markerInfo.markerType, color: color)
                    } else {
                        await MarkerImageCache.shared.image(for: markerInfo.markerType)
                    }
                    overlay.iconImage = NMFOverlayImage(image: icon)
                    markerTypes[markerInfo.id] = markerInfo.markerType
                }
                
                if case .cell = markerInfo.markerType {
                    overlay.touchHandler = { _ in
                        onCellTapped(markerInfo.id)
                        return true
                    }
                }
            } else {
                let overlay = await createMarker(
                    for: markerInfo,
                    on: mapView
                )
                markers[markerInfo.id] = overlay
                markerTypes[markerInfo.id] = markerInfo.markerType
                
                if case .cell = markerInfo.markerType {
                    overlay.touchHandler = { _ in
                        onCellTapped(markerInfo.id)
                        return true
                    }
                }
            }
        }
    }
    
    private func coordinateKey(latitude: Double, longitude: Double) -> String {
        let latString = String(format: "%.6f", latitude)
        let lngString = String(format: "%.6f", longitude)
        return "\(latString)_\(lngString)"
    }
}
