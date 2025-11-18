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
    /// 마커 색상 캐시 (markerId -> PinColorType) - 선택 해제 시 원래 색상 복원용
    private var markerColors: [String: PinColorType] = [:]
    /// 현재 선택된 마커 ID
    private var selectedMarkerId: String?
    
    // MARK: - Public Methods
    
    /// 케이스 위치 마커를 업데이트합니다.
    /// - Parameters:
    ///   - locations: 표시할 위치 데이터 배열
    ///   - mapView: 네이버 지도 뷰
    ///   - onCellTapped: 셀 마커 탭 콜백
    ///   - onUserLocationTapped: 사용자 위치 마커(home/work/custom) 탭 콜백 (Location ID 전달)
    /// - Returns: 좌표 키와 방문 횟수 매핑 (셀 타입에 한함)
    @discardableResult
    func updateMarkers(
        _ locations: [Location],
        on mapView: NMFMapView,
        onCellTapped: @escaping (String) -> Void,
        onUserLocationTapped: @escaping (UUID) -> Void
    ) async -> [String: Int] {
        let (markers, cellCounts) = buildMarkers(from: locations)
        await applyMarkers(markers, on: mapView, onCellTapped: onCellTapped, onUserLocationTapped: onUserLocationTapped)
        
        return cellCounts
    }
    
    /// 모든 마커를 제거합니다.
    func clearAll() {
        for marker in markers.values {
            marker.mapView = nil
        }
        markers.removeAll()
        markerTypes.removeAll()
        markerColors.removeAll()
        selectedMarkerId = nil
    }
    
    /// 방문 빈도 배지를 셀 마커에 적용합니다.
    /// - Parameters:
    ///   - cellCounts: 좌표 키와 방문 횟수 매핑
    ///   - mapView: 네이버 지도 뷰
    func applyVisitFrequency(with cellCounts: [String: Int], on mapView: NMFMapView) async {
        guard !cellCounts.isEmpty else { return }
        
        for (id, count) in cellCounts {
            guard let overlay = markers[id] else { continue }
            
            // 선택된 마커는 큰 핀 유지
            if id == selectedMarkerId { continue }
            
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
            
            // 선택된 마커는 큰 핀 유지
            if id == selectedMarkerId { continue }
            
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
    
    /// 마커 선택 해제
    func deselectMarker(on _: NMFMapView) async {
        guard let selectedId = selectedMarkerId,
              let marker = markers[selectedId],
              let markerType = markerTypes[selectedId] else { return }
        
        // 원래 작은 마커로 복원 (원래 색상 포함)
        let pinColor = markerColors[selectedId]
        let smallIcon = await getSmallMarkerIcon(for: markerType, pinColor: pinColor)
        marker.iconImage = NMFOverlayImage(image: smallIcon)
        marker.zIndex = 0
        
        selectedMarkerId = nil
    }
    
    private struct MarkerModel {
        let id: String
        let coordinate: MapCoordinate
        /// 사용자 위치 마커의 색상 (home / work / custom 에서만 사용)
        let pinColor: PinColorType?
        /// 핀 이름 (캡션으로 표시)
        let title: String?
        
        var markerType: MarkerType
    }
    
    // MARK: - Private Methods
    
    private func createMarker(
        for marker: MarkerModel,
        on mapView: NMFMapView,
        onCellTapped: @escaping (String) -> Void,
        onUserLocationTapped: @escaping (UUID) -> Void
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
        
        // 핀 이름을 캡션으로 표시
        if let title = marker.title, !title.isEmpty {
            overlay.captionText = title
            overlay.captionRequestedWidth = 100
        }
        
        overlay.mapView = mapView
        
        // 탭 핸들러 등록 (선택 가능한 마커만)
        if isSelectableMarker(marker.markerType) {
            overlay.touchHandler = { [weak self] _ in
                guard let self else { return false }
                Task { @MainActor in
                    await self.handleMarkerTap(
                        markerId: marker.id,
                        markerType: marker.markerType,
                        pinColor: marker.pinColor,
                        on: mapView,
                        onCellTapped: onCellTapped,
                        onUserLocationTapped: onUserLocationTapped
                    )
                }
                return true
            }
        }
        
        return overlay
    }
    
    /// 마커 탭 처리
    private func handleMarkerTap(
        markerId: String,
        markerType: MarkerType,
        pinColor: PinColorType?,
        on mapView: NMFMapView,
        onCellTapped: @escaping (String) -> Void,
        onUserLocationTapped: @escaping (UUID) -> Void
    ) async {
        // 이전 선택 해제
        await deselectMarker(on: mapView)
        
        // 새 마커 선택
        guard let marker = markers[markerId] else { return }
        
        // 큰 핀으로 변경 (MarkerType Extension 사용)
        let color = pinColor ?? .black
        guard let selectedStyle = markerType.toSelectedPinStyle(pinColor: color) else { return }
        let largeIcon = await MarkerImageCache.shared.selectedPinImage(for: selectedStyle)
        marker.iconImage = NMFOverlayImage(image: largeIcon)
        marker.zIndex = 1000 // 다른 마커 위에 표시
        
        selectedMarkerId = markerId
        
        // 마커 타입에 따라 콜백 호출
        switch markerType {
        case .cell:
            // 셀 마커면 타임라인 콜백 호출
            onCellTapped(markerId)
        case .home, .work, .custom:
            // 사용자 위치 마커면 Location ID를 UUID로 변환하여 콜백 호출
            if let locationId = UUID(uuidString: markerId) {
                onUserLocationTapped(locationId)
            }
        default:
            break
        }
    }
    
    /// 선택 가능한 마커인지 확인
    private func isSelectableMarker(_ type: MarkerType) -> Bool {
        switch type {
        case .home, .work, .custom:
            true
        case let .cell(isVisited):
            isVisited // visited cell만 선택 가능
        case .cellWithCount, .cctv:
            false
        }
    }
    
    /// 작은 마커 아이콘 가져오기 (선택 해제 시 복원용)
    private func getSmallMarkerIcon(for type: MarkerType, pinColor: PinColorType?) async -> UIImage {
        // 사용자 위치 마커는 원래 색상으로 복원
        if type.isUserLocation, let color = pinColor {
            return await MarkerImageCache.shared.userLocationImage(for: type, color: color)
        }
        
        // 셀 마커나 기타 마커는 타입에 따라 복원
        switch type {
        case let .cell(isVisited):
            return await MarkerImageCache.shared.image(for: .cell(isVisited: isVisited))
        case let .cellWithCount(count):
            return await MarkerImageCache.shared.image(for: .cellWithCount(count: count))
        default:
            return await MarkerImageCache.shared.image(for: type)
        }
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
                    title: location.title,
                    markerType: .home
                ))
            case .work:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    pinColor: pinColor,
                    title: location.title,
                    markerType: .work
                ))
            case .custom:
                markers.append(MarkerModel(
                    id: location.id.uuidString,
                    coordinate: coordinate,
                    pinColor: pinColor,
                    title: location.title,
                    markerType: .custom
                ))
            case .cell:
                break
            }
        }
        
        // 2. 기지국 방문 빈도 계산 (유틸리티 사용)
        let cellGroups = locations.visitFrequencyByCoordinate()
        
        // 3. 기지국 마커 생성
        for (key, entry) in cellGroups {
            let coordinate = MapCoordinate(latitude: entry.latitude, longitude: entry.longitude)
            markers.append(
                MarkerModel(
                    id: key,
                    coordinate: coordinate,
                    pinColor: nil,
                    title: nil,
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
    ///   - onUserLocationTapped: 사용자 위치 마커 탭 콜백
    private func applyMarkers(
        _ markerModels: [MarkerModel],
        on mapView: NMFMapView,
        onCellTapped: @escaping (String) -> Void,
        onUserLocationTapped: @escaping (UUID) -> Void
    ) async {
        let currentIds = Set(markerModels.map(\.id))
        let existingIds = Set(markers.keys)
        let idsToRemove = existingIds.subtracting(currentIds)
        
        for markerId in idsToRemove {
            markers[markerId]?.mapView = nil
            markers.removeValue(forKey: markerId)
            markerTypes.removeValue(forKey: markerId)
            markerColors.removeValue(forKey: markerId)
            
            // 삭제된 마커가 선택된 마커였다면 선택 해제
            if markerId == selectedMarkerId {
                selectedMarkerId = nil
            }
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
                
                // 선택된 마커 처리: 색상이 변경되면 큰 핀 아이콘을 새 색상으로 업데이트
                if markerInfo.id == selectedMarkerId {
                    let colorChanged = markerColors[markerInfo.id] != markerInfo.pinColor
                    if colorChanged {
                        // 색상이 변경되었으면 큰 핀 아이콘을 새 색상으로 업데이트
                        let color = markerInfo.pinColor ?? .black
                        if let selectedStyle = markerInfo.markerType.toSelectedPinStyle(pinColor: color) {
                            let largeIcon = await MarkerImageCache.shared.selectedPinImage(for: selectedStyle)
                            overlay.iconImage = NMFOverlayImage(image: largeIcon)
                            markerColors[markerInfo.id] = markerInfo.pinColor
                        }
                    }
                    // 핀 이름 캡션 업데이트
                    if let title = markerInfo.title, !title.isEmpty {
                        overlay.captionText = title
                        overlay.captionRequestedWidth = 100
                    } else { overlay.captionText = "" }
                    // 색상이 동일하면 큰 핀 유지 (continue)
                    continue
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
                    // 색상 정보 저장 (선택 해제 시 복원용)
                    markerColors[markerInfo.id] = markerInfo.pinColor
                }
                
                // 핀 이름 캡션 업데이트
                if let title = markerInfo.title, !title.isEmpty {
                    overlay.captionText = title
                    overlay.captionRequestedWidth = 100
                } else {
                    overlay.captionText = ""
                }
                
                // 탭 핸들러 등록
                if isSelectableMarker(markerInfo.markerType) {
                    overlay.touchHandler = { [weak self] _ in
                        guard let self else { return false }
                        Task { @MainActor in
                            await self.handleMarkerTap(
                                markerId: markerInfo.id,
                                markerType: markerInfo.markerType,
                                pinColor: markerInfo.pinColor,
                                on: mapView,
                                onCellTapped: onCellTapped,
                                onUserLocationTapped: onUserLocationTapped
                            )
                        }
                        return true
                    }
                }
            } else {
                let overlay = await createMarker(
                    for: markerInfo,
                    on: mapView,
                    onCellTapped: onCellTapped,
                    onUserLocationTapped: onUserLocationTapped
                )
                markers[markerInfo.id] = overlay
                markerTypes[markerInfo.id] = markerInfo.markerType
                // 색상 정보 저장 (선택 해제 시 복원용)
                markerColors[markerInfo.id] = markerInfo.pinColor
            }
        }
    }
}
