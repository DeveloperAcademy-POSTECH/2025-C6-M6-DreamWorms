//
//  OverviewNaverMapView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/14/25.
//

import CoreLocation
import NMapsMap
import SwiftUI

/// LocationOverview 화면 상단에서 사용하는 간단한 네이버 지도 뷰입니다.
///
/// - 한 개의 기준 좌표(`centerCoordinate`)를 중심으로:
///   - 기존 Cell 마커 스타일(`MarkerType.cell`)의 핀을 찍고
///   - 지정한 반경(`coverageRadius`)의 커버리지 원을 함께 보여줍니다.
/// - MapView처럼 복잡한 레이어/타임라인 연동은 없이,
///   "이 기지국을 중심으로 어느 정도 범위인가"를 시각적으로 보여주는 용도입니다.
///
struct OverviewNaverMapView: UIViewRepresentable {
    /// 지도에서 중심이 될 좌표입니다. (기지국 위치)
    let centerCoordinate: MapCoordinate
    /// 범위 안에 포함된 Location 목록 (이미 Feature에서 필터링된 값)
    let locations: [Location]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .disabled
        mapView.locationOverlay.hidden = true
        mapView.minZoomLevel = 5
        mapView.maxZoomLevel = 18
        
        context.coordinator.mapView = mapView
        
        // 초기 카메라 포지셔닝
        context.coordinator.configureInitialCamera(on: mapView)
        // 초기 마커 및 원 설정
        context.coordinator.updateCenterMarkerAndCoverage(
            centerCoordinate,
            radius: 500,
            on: mapView
        )
        // Location 마커 초기 렌더링
        context.coordinator.updateLocationMarkers(
            locations,
            on: mapView
        )
        
        return mapView
    }
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        context.coordinator.updateCenterMarkerAndCoverage(
            centerCoordinate,
            radius: 500,
            on: uiView
        )
        context.coordinator.updateLocationMarkers(
            locations,
            on: uiView
        )
    }
    
    // MARK: - Coordinator
    
    final class Coordinator: NSObject {
        weak var mapView: NMFMapView?
        let parent: OverviewNaverMapView
        
        /// 기준 기지국 마커
        private var centerMarker: NMFMarker?
        /// 커버리지 오버레이
        private var coverageOverlay: NMFGroundOverlay?
        /// Location 위치 마커들 (id -> marker)
        private var locationMarkers: [UUID: NMFMarker] = [:]
        
        init(parent: OverviewNaverMapView) {
            self.parent = parent
        }
        
        // MARK: - Camera
        
        func configureInitialCamera(on mapView: NMFMapView) {
            let center = parent.centerCoordinate
            let latlng = NMGLatLng(lat: center.latitude, lng: center.longitude)
            let camera = NMFCameraPosition(latlng, zoom: 13.5)
            let update = NMFCameraUpdate(position: camera)
            update.animation = .none
            mapView.moveCamera(update)
        }
        
        // MARK: - Marker + Coverage
        
        func updateCenterMarkerAndCoverage(
            _ center: MapCoordinate,
            radius: CLLocationDistance,
            on mapView: NMFMapView
        ) {
            let latlng = NMGLatLng(lat: center.latitude, lng: center.longitude)
            
            updateCenterMarker(at: latlng, on: mapView)
            updateCoverageOverlay(
                center: center,
                radius: radius,
                cameraLatLng: latlng,
                on: mapView
            )
        }
        
        // MARK: Center Marker
        
        private func updateCenterMarker(
            at latlng: NMGLatLng,
            on mapView: NMFMapView
        ) {
            if let marker = centerMarker {
                marker.position = latlng
            } else {
                let marker = NMFMarker()
                marker.position = latlng
                marker.mapView = mapView
                marker.anchor = CGPoint(x: 0.5, y: 1.0)
                centerMarker = marker
                
                Task { @MainActor in
                    let icon = await MarkerImageCache.shared.image(for: .cell(isVisited: true))
                    marker.iconImage = NMFOverlayImage(image: icon)
                }
            }
        }
        
        // MARK: Coverage Overlay
        
        private func updateCoverageOverlay(
            center: MapCoordinate,
            radius: CLLocationDistance,
            cameraLatLng: NMGLatLng,
            on mapView: NMFMapView
        ) {
            // bounds 계산
            let southWest = NMGLatLng(
                lat: center.latitude - metersToDegrees(radius),
                lng: center.longitude - metersToDegreesLongitude(radius, at: center.latitude)
            )
            let northEast = NMGLatLng(
                lat: center.latitude + metersToDegrees(radius),
                lng: center.longitude + metersToDegreesLongitude(radius, at: center.latitude)
            )
            let bounds = NMGLatLngBounds(southWest: southWest, northEast: northEast)
            
            // coverage overlay 적용
            Task { @MainActor in
                let overlayImage = await RangeOverlayImageCache.shared.image(for: .half)
                
                if let coverage = coverageOverlay {
                    coverage.bounds = bounds
                } else {
                    let coverage = NMFGroundOverlay(
                        bounds: bounds,
                        image: NMFOverlayImage(image: overlayImage)
                    )
                    coverage.alpha = 0.55
                    coverage.mapView = mapView
                    coverageOverlay = coverage
                }
                
                // overlay 적용 후 카메라를 다시 정확한 중심으로 이동
                DispatchQueue.main.async {
                    let update = NMFCameraUpdate(
                        position: NMFCameraPosition(cameraLatLng, zoom: 13.5)
                    )
                    update.animation = .none
                    mapView.moveCamera(update)
                }
            }
        }
        
        /// Overview 범위 안의 Location들을 타입에 맞는 마커로 렌더링합니다.
        /// - Parameter locations: 이미 Feature에서 반경 + 타입 필터링이 끝난 Location 배열
        func updateLocationMarkers(
            _ locations: [Location],
            on mapView: NMFMapView
        ) {
            // Location -> MarkerModel 매핑
            struct MarkerModel {
                let id: UUID
                let coordinate: MapCoordinate
                let markerType: MarkerType
            }
            
            var models: [UUID: MarkerModel] = [:]
            
            for loc in locations {
                let lat = loc.pointLatitude
                let lon = loc.pointLongitude
                guard lat != 0, lon != 0 else { continue }
                
                // LocationType -> MarkerType 매핑
                let markerType: MarkerType
                switch LocationType(loc.locationType) {
                case .home: markerType = .home
                case .work: markerType = .work
                case .custom: markerType = .custom
                case .cell: continue
                }
                
                let coord = MapCoordinate(latitude: lat, longitude: lon)
                models[loc.id] = MarkerModel(
                    id: loc.id,
                    coordinate: coord,
                    markerType: markerType
                )
            }
            
            let newIds = Set(models.keys)
            let oldIds = Set(locationMarkers.keys)
            
            // 사라진 마커 제거
            let idsToRemove = oldIds.subtracting(newIds)
            for id in idsToRemove {
                locationMarkers[id]?.mapView = nil
                locationMarkers.removeValue(forKey: id)
            }
            
            // 새/변경된 마커 적용
            Task { @MainActor in
                for model in models.values {
                    let position = NMGLatLng(
                        lat: model.coordinate.latitude,
                        lng: model.coordinate.longitude
                    )
                    
                    if let marker = locationMarkers[model.id] {
                        marker.position = position
                        if marker.mapView == nil {
                            marker.mapView = mapView
                        }
                    } else {
                        let marker = NMFMarker()
                        marker.position = position
                        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                        marker.anchor = CGPoint(x: 0.5, y: 1.0)
                        
                        let icon = await MarkerImageCache.shared.image(for: model.markerType)
                        marker.iconImage = NMFOverlayImage(image: icon)
                        marker.mapView = mapView
                        
                        locationMarkers[model.id] = marker
                    }
                }
            }
        }
        
        // MARK: - Utility: meters → degrees
        
        private func metersToDegrees(_ meters: CLLocationDistance) -> Double {
            meters / 111_320.0
        }
        
        private func metersToDegreesLongitude(_ meters: CLLocationDistance, at latitude: Double) -> Double {
            meters / (111_320.0 * cos(latitude * .pi / 180))
        }
    }
}
