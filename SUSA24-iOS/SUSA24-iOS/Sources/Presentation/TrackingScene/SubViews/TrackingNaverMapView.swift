//
//  TrackingNaverMapView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import NMapsGeometry
import NMapsMap
import SwiftUI

struct TrackingNaverMapView: UIViewRepresentable {
    /// 지도에 표시할 위치 배열 (TrackingFeature.State.locations)
    var locations: [Location]
    
    /// 현재 선택된 Location ID 모음 (선택 상태 표현에 사용할 수 있음)
    var selectedLocationIDs: Set<UUID>
    
    /// CCTV 검색 결과
    var cctvMarkers: [CCTVMarker]
    
    /// 마커를 탭했을 때 상위로 전달할 콜백
    /// - Parameters:
    ///   - id: Location.id
    ///   - name: 슬롯에 표시할 이름 (title 없으면 address)
    var onLocationTapped: (UUID, String) -> Void
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .normal
        mapView.locationOverlay.hidden = false
        context.coordinator.mapView = mapView
        
        let cameraUpdate = NMFCameraUpdate(zoomTo: 14)
        cameraUpdate.animation = .none
        mapView.moveCamera(cameraUpdate)
        
        return mapView
    }
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.mapView = uiView
        
        context.coordinator.updateLocationMarkers(
            locations: locations,
            selectedIDs: selectedLocationIDs,
            on: uiView
        )
        
        context.coordinator.updateCCTVMarkers(
            cctvMarkers: cctvMarkers,
            on: uiView
        )
    }
}

extension TrackingNaverMapView {
    final class Coordinator: NSObject {
        weak var mapView: NMFMapView?
        var parent: TrackingNaverMapView
        
        /// Location.id -> NMFMarker 매핑
        private var markers: [UUID: NMFMarker] = [:]
        
        /// Location.id -> Location (터치 시 이름 얻는 용도)
        private var locationCache: [UUID: Location] = [:]
        
        /// 가장 최근 위치로 카메라를 한 번이라도 맞췄는지 여부
        private var didSetInitialCamera = false
        
        /// 선택된 위치들을 연결할 Path 오버레이
        private var selectionPath: NMFPath?

        /// 선택된 위치들로 만드는 폴리곤(삼각형) 오버레이
        private var selectionPolygon: NMFPolygonOverlay?
        
        private let infrastructureManager = InfrastructureMarkerManager()
        
        init(parent: TrackingNaverMapView) {
            self.parent = parent
        }
        
        // MARK: - Public
        
        /// Location 배열을 기반으로 마커를 업데이트합니다.
        @MainActor
        func updateLocationMarkers(
            locations: [Location],
            selectedIDs: Set<UUID>,
            on mapView: NMFMapView
        ) {
            locationCache = Dictionary(uniqueKeysWithValues: locations.map { ($0.id, $0) })
            
            let newIds = Set(locations.map(\.id))
            let existingIds = Set(markers.keys)
            
            // 1) 더 이상 존재하지 않는 ID의 마커 제거
            let idsToRemove = existingIds.subtracting(newIds)
            for id in idsToRemove {
                markers[id]?.mapView = nil
                markers.removeValue(forKey: id)
            }
            
            // 2) 새로 추가되거나 변경된 위치들 처리
            for location in locations {
                guard location.pointLatitude != 0, location.pointLongitude != 0 else { continue }
                
                if let marker = markers[location.id] {
                    // 기존 마커 업데이트
                    update(
                        marker: marker,
                        with: location,
                        isSelected: selectedIDs.contains(location.id),
                        on: mapView
                    )
                } else {
                    // 새 마커 생성
                    let marker = makeMarker(
                        for: location,
                        isSelected: selectedIDs.contains(location.id),
                        on: mapView
                    )
                    markers[location.id] = marker
                }
            }
            
            // 아직 초기 카메라를 세팅하지 않았고, 표시할 위치가 있다면
            if !didSetInitialCamera,
               let targetLocation = latestLocation(from: locations)
            {
                centerCamera(on: targetLocation, in: mapView)
                didSetInitialCamera = true
            }
            
            // Path를 선택했을 때 라인 그리기
            updateSelectionPath(selectedIDs: selectedIDs, on: mapView)
        }
        
        // MARK: - Private: Camera
        
        /// 좌표가 유효한 Location들 중, 가장 최근에 저장된 Location을 반환합니다.
        private func latestLocation(from locations: [Location]) -> Location? {
            locations
                .filter { $0.pointLatitude != 0 && $0.pointLongitude != 0 }
                .max { lhs, rhs in
                    let lhsDate = lhs.receivedAt ?? .distantPast
                    let rhsDate = rhs.receivedAt ?? .distantPast
                    return lhsDate < rhsDate
                }
        }
        
        /// 주어진 Location 기반으로 카메라를 이동합니다.
        @MainActor
        private func centerCamera(on location: Location, in mapView: NMFMapView) {
            let target = NMGLatLng(
                lat: location.pointLatitude,
                lng: location.pointLongitude
            )
            let position = NMFCameraPosition(target, zoom: 15)
            let update = NMFCameraUpdate(position: position)
            update.animation = .none
            mapView.moveCamera(update)
        }
        
        // MARK: - Private: Marker
        
        /// Location 기반으로 새로운 마커를 생성합니다.
        @MainActor
        private func makeMarker(
            for location: Location,
            isSelected: Bool,
            on mapView: NMFMapView
        ) -> NMFMarker {
            let marker = NMFMarker()
            marker.position = NMGLatLng(
                lat: location.pointLatitude,
                lng: location.pointLongitude
            )
            
            // 아이콘 설정
            Task { @MainActor in
                marker.iconImage = await iconImage(for: location, isSelected: isSelected)
            }
            
            marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
            marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
            marker.mapView = mapView
            
            let id = location.id
            marker.touchHandler = { [weak self] _ in
                guard let self else { return true }
                
                // 중복 선택 방지
                if parent.selectedLocationIDs.contains(id) {
                    return true
                }
                
                guard let tappedLocation = locationCache[id] else { return true }
                
                let name: String = if let title = tappedLocation.title, !title.isEmpty {
                    title
                } else {
                    tappedLocation.address
                }
                
                parent.onLocationTapped(id, name)
                return true
            }
            
            return marker
        }
        
        /// 기존 마커를 Location 정보에 맞게 업데이트합니다.
        @MainActor
        private func update(
            marker: NMFMarker,
            with location: Location,
            isSelected: Bool,
            on mapView: NMFMapView
        ) {
            marker.position = NMGLatLng(
                lat: location.pointLatitude,
                lng: location.pointLongitude
            )
            
            if marker.mapView == nil { marker.mapView = mapView }
            
            // 선택 상태에 따라 아이콘 교체
            Task { @MainActor in
                marker.iconImage = await iconImage(for: location, isSelected: isSelected)
            }
        }
        
        /// LocationType + 선택 상태에 따른 아이콘 이미지를 반환합니다.
        /// - 프로젝트에서 이미 사용 중인 MarkerType / MarkerImageCache를 활용하는 버전
        @MainActor
        private func iconImage(
            for location: Location,
            isSelected: Bool
        ) async -> NMFOverlayImage {
            let pinColor = PinColorType(location.colorType)
            let locationType = LocationType(location.locationType)
            
            // 선택된 경우: SelectedPinStyle 기반 큰 핀 사용
            if isSelected,
               let style = selectedPinStyle(for: location),
               let uiImage = selectedPinUIImage(for: style)
            {
                return NMFOverlayImage(image: uiImage)
            }
            
            // 선택되지 않은 경우: 기존 동그라미 마커 스타일 유지
            let markerType: MarkerType = switch locationType {
            case .home: .home
            case .work: .work
            case .custom: .custom
            case .cell: .cell(isVisited: true)
            }
            
            let image: UIImage = if markerType.isUserLocation {
                await MarkerImageCache.shared.userLocationImage(for: markerType, color: pinColor)
            } else {
                await MarkerImageCache.shared.image(for: markerType)
            }
            
            return NMFOverlayImage(image: image)
        }
        
        @MainActor
        private func updateSelectionPath(
            selectedIDs: Set<UUID>,
            on mapView: NMFMapView
        ) {
            // 선택된 Location만 추출
            let selectedLocations = selectedIDs
                .compactMap { locationCache[$0] }
                .filter { $0.pointLatitude != 0 && $0.pointLongitude != 0 }
            
            // 2개 미만이면 모든 오버레이 제거
            guard selectedLocations.count >= 2 else {
                selectionPath?.mapView = nil
                selectionPolygon?.mapView = nil
                return
            }
            
            let points: [NMGLatLng] = selectedLocations.map {
                NMGLatLng(lat: $0.pointLatitude, lng: $0.pointLongitude)
            }
            
            if selectedLocations.count == 2 {
                selectionPolygon?.mapView = nil
                
                let pathOverlay: NMFPath
                if let existing = selectionPath {
                    pathOverlay = existing
                } else {
                    pathOverlay = NMFPath()
                    selectionPath = pathOverlay
                }
                
                pathOverlay.path = NMGLineString(points: points)
                pathOverlay.color = .primaryNormal
                pathOverlay.width = 2
                pathOverlay.outlineWidth = 0
                
                pathOverlay.mapView = mapView
            } else {
                selectionPath?.mapView = nil
                
                var ringPoints = points
                if let first = points.first,
                   let last = points.last,
                   first.lat != last.lat || first.lng != last.lng
                {
                    ringPoints.append(first)
                }
                
                let ring = NMGLineString(points: ringPoints)
                let polygon: NMGPolygon<AnyObject> = NMGPolygon(ring: ring) as! NMGPolygon<AnyObject>
                
                let polygonOverlay: NMFPolygonOverlay
                if let existing = selectionPolygon {
                    polygonOverlay = existing
                    polygonOverlay.polygon = polygon
                } else {
                    polygonOverlay = NMFPolygonOverlay(polygon) ?? NMFPolygonOverlay()
                    selectionPolygon = polygonOverlay
                }
                
                polygonOverlay.fillColor = UIColor.primaryNormal.withAlphaComponent(0.11)
                polygonOverlay.outlineColor = .primaryNormal
                polygonOverlay.outlineWidth = 2
                
                polygonOverlay.mapView = mapView
            }
        }
        
        @MainActor
        func updateCCTVMarkers(
            cctvMarkers: [CCTVMarker],
            on mapView: NMFMapView
        ) {
            infrastructureManager.updateCCTVs(
                cctvMarkers,
                on: mapView,
                isVisible: !cctvMarkers.isEmpty
            )
        }
        
        private func selectedPinStyle(for location: Location) -> SelectedPinStyle? {
            let color = PinColorType(location.colorType)
            switch LocationType(location.locationType) {
            case .home:
                return .home(color)
            case .work:
                return .work(color)
            case .custom:
                return .custom(color)
            case .cell:
                return .cell(color)
            }
        }

        /// SelectedPinStyle을 이미지셋 이름 → UIImage 로 변환
        private func selectedPinUIImage(for style: SelectedPinStyle) -> UIImage? {
            // MarkerImage.swift 의 SelectedPinStyle.pinColorAssetName 를 그대로 복붙해도 OK
            func pinColorAssetName(_ color: PinColorType) -> String {
                switch color {
                case .black: "black"
                case .red: "red"
                case .orange: "orange"
                case .yellow: "yellow"
                case .lightGreen: "lightGreen"
                case .darkGreen: "darkGreen"
                case .purple: "purple"
                }
            }
            
            let colorName = pinColorAssetName(style.pinColor)
            let assetName: String = switch style {
            case .home: "pin_home_\(colorName)"
            case .work: "pin_work_\(colorName)"
            case .cell: "pin_cell"
            case .custom: "pin_custom_\(colorName)"
            }
            
            return UIImage(named: assetName)
        }
    }
}
