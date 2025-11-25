//
//  InfrastructureLayerManager.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/12/25.
//

import Foundation
import NMapsMap

/// 인프라 레이어 (기지국, CCTV) 마커를 관리하는 매니저
/// - 기지국 마커의 생성, 업데이트, 삭제 담당
/// - Diff 알고리즘으로 변경된 부분만 처리하여 성능 최적화
@MainActor
final class InfrastructureMarkerManager {
    // MARK: - Properties
    
    /// 기지국 마커 저장소 (stationId -> NMFMarker)
    private var cellMarkers: [String: NMFMarker] = [:]
    /// CCTV 마커 저장소 (cctvId -> NMFMarker)
    private var cctvMarkers: [String: NMFMarker] = [:]
    /// 기지국 커버리지 오버레이 저장소 (stationId -> NMFGroundOverlay)
    private var cellRangeOverlays: [String: NMFGroundOverlay] = [:]
    
    // MARK: - Public Methods
    
    /// 기지국 데이터를 업데이트하고 지도에 마커를 표시합니다.
    /// - Diff 알고리즘: 새로운 마커만 생성하고, 기존 마커는 재사용
    /// - Parameters:
    ///   - cellStations: 표시할 기지국 데이터 배열
    ///   - mapView: 네이버 지도 뷰
    ///   - isVisible: 마커 초기 표시 여부 (기본값: false)
    func updateCellStations(
        _ cellStations: [CellMarker],
        on mapView: NMFMapView,
        isVisible: Bool = false
    ) {
        // 1. Diff 계산: 어떤 마커를 추가/삭제할지 결정
        let currentStationIds = Set(cellStations.map(\.id))
        let existingMarkerIds = Set(cellMarkers.keys)
        
        let idsToRemove = existingMarkerIds.subtracting(currentStationIds)
        let idsToAdd = currentStationIds.subtracting(existingMarkerIds)
        
        // 2. 삭제할 마커 제거 (동기: 즉시 반영)
        for stationId in idsToRemove {
            cellMarkers[stationId]?.mapView = nil
            cellMarkers.removeValue(forKey: stationId)
        }
        
        // 3. 새로운 마커 추가 (비동기: UI 블로킹 방지)
        Task {
            for station in cellStations where idsToAdd.contains(station.id) {
                let marker = await createMarker(for: station, on: mapView, isVisible: isVisible)
                cellMarkers[station.id] = marker
            }
        }
    }
    
    /// CCTV 데이터를 업데이트하고 지도에 마커를 표시합니다.
    /// - Parameters:
    ///   - cctvMarkers: 표시할 CCTV 정보 배열
    ///   - mapView: 네이버 지도 뷰
    ///   - isVisible: 마커 초기 표시 여부
    func updateCCTVs(
        _ cctvMarkers: [CCTVMarker],
        on mapView: NMFMapView,
        isVisible: Bool
    ) {
        let currentIds = Set(cctvMarkers.map(\.id))
        let existingIds = Set(self.cctvMarkers.keys)
        
        let idsToRemove = existingIds.subtracting(currentIds)
        let idsToAdd = currentIds.subtracting(existingIds)
        
        for cctvId in idsToRemove {
            self.cctvMarkers[cctvId]?.mapView = nil
            self.cctvMarkers.removeValue(forKey: cctvId)
        }
        
        Task {
            for marker in cctvMarkers where idsToAdd.contains(marker.id) {
                let overlay = await createCCTVMarker(for: marker, on: mapView, isVisible: isVisible)
                self.cctvMarkers[marker.id] = overlay
            }
        }
    }
    
    /// 모든 기지국 마커의 표시/숨김을 전환합니다.
    /// - Parameter isVisible: true면 표시, false면 숨김
    func setCellVisibility(_ isVisible: Bool) {
        for marker in cellMarkers.values {
            marker.hidden = !isVisible
        }
    }
    
    /// 모든 CCTV 마커의 표시/숨김을 전환합니다.
    /// - Parameter isVisible: true면 표시, false면 숨김
    func setCCTVVisibility(_ isVisible: Bool) {
        for marker in cctvMarkers.values {
            marker.hidden = !isVisible
        }
    }
    
    /// 모든 마커를 지도에서 제거하고 메모리를 정리합니다.
    func clearAll() {
        for marker in cellMarkers.values {
            marker.mapView = nil
        }
        cellMarkers.removeAll()
        for overlay in cellRangeOverlays.values {
            overlay.mapView = nil
        }
        cellRangeOverlays.removeAll()
        
        for marker in cctvMarkers.values {
            marker.mapView = nil
        }
        cctvMarkers.removeAll()
    }
    
    // MARK: - Private Methods
    
    /// 마커에 레이어 옵션을 적용합니다.
    /// - Parameters:
    ///   - marker: 레이어 옵션을 적용할 마커
    ///   - markerType: 마커 타입
    private func applyMarkerLayerOptions(to marker: NMFMarker, markerType: MarkerType) {
        marker.zIndex = markerType.zIndex
        marker.isHideCollidedSymbols = markerType.shouldHideCollidedSymbols
        marker.isHideCollidedMarkers = markerType.shouldHideCollidedMarkers
        marker.isForceShowIcon = markerType.shouldForceShowIcon
        marker.isHideCollidedCaptions = markerType.shouldHideCollidedCaptions
    }
    
    /// 기지국 마커를 생성합니다.
    /// - Parameters:
    ///   - station: 기지국 데이터
    ///   - mapView: 네이버 지도 뷰
    ///   - isVisible: 마커 초기 표시 여부
    /// - Returns: 생성된 NMFMarker
    private func createMarker(
        for station: CellMarker,
        on mapView: NMFMapView,
        isVisible: Bool
    ) async -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: station.latitude, lng: station.longitude)
        let markerImage = await MarkerImageCache.shared.image(for: station.markerType)
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.hidden = !isVisible
        
        // 레이어 속성 적용
        applyMarkerLayerOptions(to: marker, markerType: station.markerType)
        
        marker.mapView = mapView
        return marker
    }
    
    private func createCCTVMarker(
        for info: CCTVMarker,
        on mapView: NMFMapView,
        isVisible: Bool
    ) async -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: info.latitude, lng: info.longitude)
        let markerImage = await MarkerImageCache.shared.image(for: .cctv)
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.hidden = !isVisible
        
        // 레이어 속성 적용
        applyMarkerLayerOptions(to: marker, markerType: .cctv)
        
        marker.mapView = mapView
        return marker
    }
    
    /// 기지국 커버리지 범위 오버레이를 갱신합니다.
    /// - Parameters:
    ///   - cellStations: 기준이 되는 기지국 마커 목록
    ///   - coverageRange: 커버리지 반경 타입
    ///   - isVisible: 오버레이 표시 여부
    ///   - mapView: 네이버 지도 뷰
    func updateCellRanges(
        _ cellStations: [CellMarker],
        coverageRange: CoverageRangeType,
        isVisible: Bool,
        on mapView: NMFMapView
    ) async {
        let stationIds = Set(cellStations.map(\.id))
        let overlaysToRemove = cellRangeOverlays.keys.filter { !stationIds.contains($0) }
        for id in overlaysToRemove {
            cellRangeOverlays[id]?.mapView = nil
            cellRangeOverlays.removeValue(forKey: id)
        }
        
        guard isVisible else {
            cellRangeOverlays.values.forEach { $0.mapView = nil }
            return
        }
        
        let overlayImage = await RangeOverlayImageCache.shared.image(for: coverageRange)
        let radius = CoverageRangeMetadata.radiusMeters(for: coverageRange)
        let overlaySource = NMFOverlayImage(image: overlayImage)
        
        for station in cellStations {
            let coordinate = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
            let bounds = NMGLatLngBounds.coverageBounds(center: coordinate, radiusMeters: radius)
            
            let overlay: NMFGroundOverlay
            if let existing = cellRangeOverlays[station.id] {
                overlay = existing
            } else {
                overlay = NMFGroundOverlay()
                cellRangeOverlays[station.id] = overlay
            }
            
            overlay.overlayImage = overlaySource
            overlay.bounds = bounds
            overlay.mapView = mapView
        }
    }
}
