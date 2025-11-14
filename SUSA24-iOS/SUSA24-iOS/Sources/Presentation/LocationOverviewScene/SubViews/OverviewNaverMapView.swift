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
        
        return mapView
    }
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        context.coordinator.updateCenterMarkerAndCoverage(
            centerCoordinate,
            radius: 500,
            on: uiView
        )
    }
    
    // MARK: - Coordinator

    class Coordinator: NSObject {
        weak var mapView: NMFMapView?
        let parent: OverviewNaverMapView
        
        private var centerMarker: NMFMarker?
        private var coverageOverlay: NMFGroundOverlay?
        
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
            
            // 1) 마커 갱신
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
            
            // 2) bounds 계산
            let sw = NMGLatLng(
                lat: center.latitude - metersToDegrees(radius),
                lng: center.longitude - metersToDegreesLongitude(radius, at: center.latitude)
            )
            
            let ne = NMGLatLng(
                lat: center.latitude + metersToDegrees(radius),
                lng: center.longitude + metersToDegreesLongitude(radius, at: center.latitude)
            )
            
            let bounds = NMGLatLngBounds(southWest: sw, northEast: ne)
            
            // 3) coverage overlay 적용
            Task { @MainActor in
                let overlayImage = await RangeOverlayImageCache.shared.image(for: .half)
                
                if let coverage = coverageOverlay {
                    coverage.bounds = bounds
                } else {
                    let coverage = NMFGroundOverlay(bounds: bounds, image: NMFOverlayImage(image: overlayImage))
                    coverage.alpha = 0.55
                    coverage.mapView = mapView
                    coverageOverlay = coverage
                }
                
                // 4) overlay 적용 후 카메라를 다시 정확한 중심으로 이동
                DispatchQueue.main.async {
                    let update = NMFCameraUpdate(position: NMFCameraPosition(latlng, zoom: 13.5))
                    update.animation = .none
                    mapView.moveCamera(update)
                }
            }
        }
        
        // MARK: - Utility: meters → degrees

        private func metersToDegrees(_ meters: CLLocationDistance) -> Double {
            meters / 111_320.0 // 경도/위도 환산
        }
        
        private func metersToDegreesLongitude(_ meters: CLLocationDistance, at latitude: Double) -> Double {
            meters / (111_320.0 * cos(latitude * .pi / 180))
        }
    }
}
