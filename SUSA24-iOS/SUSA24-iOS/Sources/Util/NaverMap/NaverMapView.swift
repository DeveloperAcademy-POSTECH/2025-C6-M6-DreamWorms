//
//  NaverMapView.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//

import CoreLocation
import NMapsMap
import SwiftUI

/// SwiftUI에서 네이버 지도 SDK를 사용하기 위한 래퍼 뷰
struct NaverMapView: UIViewRepresentable {
    // MARK: 카메라 이동 명령
    
    /// 외부 모듈이 요청한 카메라 목표 좌표입니다. 값이 바뀔 때마다 카메라를 이동합니다.
    var cameraTargetCoordinate: MapCoordinate?
    /// 카메라 이동 시 애니메이션을 적용할지 여부입니다.
    var shouldAnimateCameraTarget: Bool = false
    /// 외부 모듈이 현위치를 포커싱해야 함을 알리는 플래그입니다.
    var shouldFocusMyLocation: Bool = false
    
    // MARK: 명령 처리 결과 콜백
    
    /// 카메라 이동 명령을 소비했음을 상위 모듈에 알리는 콜백입니다.
    var onCameraMoveConsumed: (() -> Void)?
    /// 현위치 포커싱 명령을 소비했음을 상위 모듈에 알리는 콜백입니다.
    var onMyLocationFocusConsumed: (() -> Void)?
    /// 기지국 셀 마커 탭 이벤트를 상위 모듈로 전달하는 콜백입니다.
    var onCellMarkerTapped: ((String, String?) -> Void)?
    /// 사용자 위치 마커(home/work/custom) 탭 이벤트를 상위 모듈로 전달하는 콜백입니다.
    var onUserLocationMarkerTapped: ((UUID) -> Void)?
    
    // MARK: 맵 터치 모드
    
    /// 지도 터치 활성화 여부입니다.
    /// - `true`: 지도 터치 이벤트 처리 (시트가 최소 높이일 때)
    /// - `false`: 지도 터치 이벤트 차단 (시트가 중간/최대 높이일 때)
    var isMapTouchEnabled: Bool = true
    /// 타임라인 시트가 최소 높이인지 여부입니다.
    /// - `true`: 타임라인 시트가 최소 높이 (PlaceInfoSheet 표시 가능)
    /// - `false`: 타임라인 시트가 올라와 있음 (PlaceInfoSheet 표시 안 함)
    var isTimelineSheetMinimized: Bool = true
    
    // MARK: 사용자 상호작용 콜백
    
    /// 지도 터치 이벤트를 상위 모듈로 전달하는 콜백입니다.
    var onMapTapped: ((NMGLatLng) -> Void)?
    /// 마커 선택 해제 트리거 (PlaceInfoSheet 닫힐 때 사용)
    var deselectMarkerTrigger: UUID?
    /// 카메라 이동이 멈췄을 때 호출되는 콜백입니다.
    var onCameraIdle: ((MapBounds, Double) -> Void)?
    /// 기지국 데이터
    var cellStations: [CellMarker] = []
    /// 기지국 레이어 표시 여부
    var isCellLayerEnabled: Bool = false
    /// 케이스 위치 데이터
    var locations: [Location] = []
    /// 방문 빈도 오버레이 표시 여부
    var isVisitFrequencyEnabled: Bool = false
    /// 기지국 범위 오버레이 표시 여부
    var isCellRangeVisible: Bool = false
    /// 기지국 범위 타입
    var cellCoverageRange: CoverageRangeType = .half
    /// CCTV 데이터
    var cctvMarkers: [CCTVMarker] = []
    /// CCTV 레이어 표시 여부
    var isCCTVLayerEnabled: Bool = false
    
    // MARK: - Dependencies
    
    /// 인프라 마커 관리자
    let infrastructureManager: InfrastructureMarkerManager
    /// 용의자 마커 관리자
    let caseLocationMarkerManager: CaseLocationMarkerManager
    
    // MARK: - UIViewRepresentable
    
    /// 네이버 지도 컨트롤을 관리할 코디네이터를 생성합니다.
    func makeCoordinator() -> Coordinator {
        Coordinator(
            parent: self,
            infrastructureManager: infrastructureManager,
            caseLocationMarkerManager: caseLocationMarkerManager
        )
    }
    
    /// 네이버 지도 뷰를 생성하고 초기 설정을 수행합니다.
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.touchDelegate = context.coordinator
        mapView.addCameraDelegate(delegate: context.coordinator)
        mapView.positionMode = .normal
        mapView.locationOverlay.hidden = false
        context.coordinator.mapView = mapView
        return mapView
    }

    /// SwiftUI 상태에 맞게 네이버 지도 뷰를 갱신합니다.
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        context.coordinator.mapView = uiView
        
        // 1) 외부에서 요청한 카메라 이동 명령 적용
        if let coordinate = cameraTargetCoordinate, context.coordinator.lastCameraTarget != coordinate {
            context.coordinator.lastCameraTarget = coordinate
            if shouldAnimateCameraTarget {
                context.coordinator.moveCamera(to: coordinate, animated: true, duration: 0.7)
            } else {
                context.coordinator.moveCamera(to: coordinate)
            }
            Task { @MainActor in
                onCameraMoveConsumed?()
            }
        } else if cameraTargetCoordinate == nil {
            context.coordinator.lastCameraTarget = nil
        }
        
        // 2) 현위치 포커싱 명령 적용
        if shouldFocusMyLocation {
            let mapView = uiView
            mapView.positionMode = .normal
            let overlay = mapView.locationOverlay
            let success = overlay.hidden == false
            if success {
                let currentLocation = overlay.location
                let coordinate = MapCoordinate(latitude: currentLocation.lat, longitude: currentLocation.lng)
                context.coordinator.moveCamera(to: coordinate, animated: true, duration: 0.7)
            }
            Task { @MainActor in
                if success {
                    onMyLocationFocusConsumed?()
                } else {
                    // TODO: - 위치를 아직 못받았을 때의 로그 등 필요하면 여기에서 처리
                    onMyLocationFocusConsumed?()
                }
            }
        }
        
        /// 지도 줌 레벨에 따라 레이어 표시 여부를 계산합니다.
        let zoomLevel = uiView.zoomLevel
        let shouldShowMarkers = zoomLevel > 11.5
        let cellLayerVisible = shouldShowMarkers && isCellLayerEnabled
        let cctvLayerVisible = shouldShowMarkers && isCCTVLayerEnabled
        
        // 3) 레이어 업데이트
        context.coordinator.updateCellLayer(
            cellMarkers: cellStations,
            isVisible: cellLayerVisible,
            on: uiView
        )
        context.coordinator.updateCaseLocations(
            locations: locations,
            visitFrequencyEnabled: isVisitFrequencyEnabled,
            isVisible: shouldShowMarkers,
            on: uiView
        )
        context.coordinator.updateCellRangeOverlay(
            cellMarkers: context.coordinator.makeVisitedCellMarkers(from: locations),
            coverageRange: cellCoverageRange,
            isVisible: isCellRangeVisible,
            on: uiView
        )
        context.coordinator.updateCCTVLayer(
            cctvMarkers: cctvMarkers,
            isVisible: cctvLayerVisible,
            on: uiView
        )

        context.coordinator.updateMarkerVisibility(
            isCaseLocationVisible: shouldShowMarkers,
            isCellMarkerVisible: cellLayerVisible,
            isCCTVVisible: cctvLayerVisible
        )
        
        // 마커 선택 해제 트리거 처리
        if let trigger = deselectMarkerTrigger, trigger != context.coordinator.lastDeselectMarkerTrigger {
            context.coordinator.lastDeselectMarkerTrigger = trigger
            Task { @MainActor in
                await context.coordinator.deselectMarker()
            }
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate, CLLocationManagerDelegate {
        /// 네이버 지도 뷰 인스턴스에 대한 약한 참조입니다.
        weak var mapView: NMFMapView?
        let parent: NaverMapView
        
        var lastCameraTarget: MapCoordinate?
        var defaultZoomLevel: Double = 15
        
        private let infrastructureManager: InfrastructureMarkerManager
        private let caseLocationMarkerManager: CaseLocationMarkerManager
        var lastDeselectMarkerTrigger: UUID?
        private var lastCellStationsHash: Int?
        private var lastLocationsHash: Int?
        private var lastCellRangeConfig: CellRangeConfig?
        private var lastCCTVMarkersHash: Int?
        private var lastCellMarkerVisibility: Bool?
        private var lastCCTVVisibility: Bool?
        
        private let locationManager = CLLocationManager()
        private var lastKnownLocation: CLLocationCoordinate2D?
        private var hasCenteredOnUserOnce = false

        init(
            parent: NaverMapView,
            infrastructureManager: InfrastructureMarkerManager,
            caseLocationMarkerManager: CaseLocationMarkerManager
        ) {
            self.parent = parent
            self.infrastructureManager = infrastructureManager
            self.caseLocationMarkerManager = caseLocationMarkerManager
            super.init()
            
            // 위치 권한 요청 및 업데이트 시작
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        /// 위치 권한 상태가 변경될 때 호출되는 메서드입니다.
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status = manager.authorizationStatus
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.startUpdatingLocation()
            default:
                break
            }
        }

        /// 새로운 위치 정보가 들어올 때마다 호출되는 메서드입니다.
        func locationManager(
            _: CLLocationManager,
            didUpdateLocations locations: [CLLocation]
        ) {
            guard let location = locations.last else { return }
            let coordinate = location.coordinate
            lastKnownLocation = coordinate

            if let mapView {
                let overlay = mapView.locationOverlay
                overlay.location = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
                overlay.hidden = false
            }

            if !hasCenteredOnUserOnce {
                hasCenteredOnUserOnce = true
                let target = MapCoordinate(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                moveCamera(to: target)
            }
        }

        // TODO: - 위치 정보 에러 발생 시 분기 처리 로직 포함
        func locationManager(
            _: CLLocationManager,
            didFailWithError error: Error
        ) {
            print("위치 업데이트 가져오기를 실패했습니다.: \(error)")
        }

        /// 마커 가시성 상태를 추적하고 네이버 지도 오버레이에 적용합니다.
        /// CaseLocation 마커는 updateCaseLocations에서 이미 처리되므로 여기서는 CellMarker와 CCTV만 처리합니다.
        @MainActor
        func updateMarkerVisibility(
            isCaseLocationVisible _: Bool,
            isCellMarkerVisible: Bool,
            isCCTVVisible: Bool
        ) {
            // CaseLocation은 updateCaseLocations에서 이미 처리됨
            
            if lastCellMarkerVisibility != isCellMarkerVisible {
                lastCellMarkerVisibility = isCellMarkerVisible
                infrastructureManager.setCellVisibility(isCellMarkerVisible)
            }
            
            if lastCCTVVisibility != isCCTVVisible {
                lastCCTVVisibility = isCCTVVisible
                infrastructureManager.setCCTVVisibility(isCCTVVisible)
            }
        }
        
        /// 지도 터치 이벤트를 SwiftUI 상위 모듈로 전달합니다.
        func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
            // 지도 터치가 비활성화되어 있으면 이벤트를 처리하지 않습니다.
            guard parent.isMapTouchEnabled else { return }
            
            // 마커 선택 해제
            Task { @MainActor in
                await deselectMarker()
            }
            
            // 타임라인 시트를 최소 높이로 내리도록 요청 (detent 제어)
            NotificationCenter.default.post(name: .resetDetentToShort, object: nil)
            
            // 타임라인 시트가 올라와 있으면 PlaceInfoSheet 표시 안 함
            guard parent.isTimelineSheetMinimized else { return }
            
            // PlaceInfoSheet 표시를 위한 콜백 호출
            parent.onMapTapped?(latlng)
        }
        
        /// 마커 선택 해제를 수행합니다.
        @MainActor
        func deselectMarker() async {
            guard let mapView else { return }
            await caseLocationMarkerManager.deselectMarker(on: mapView)
        }
        
        @MainActor
        func updateCaseLocations(
            locations: [Location],
            visitFrequencyEnabled: Bool,
            isVisible: Bool,
            on mapView: NMFMapView
        ) {
            var hasher = Hasher()
            for location in locations {
                hasher.combine(location.id)
                hasher.combine(location.locationType)
                hasher.combine(location.pointLatitude)
                hasher.combine(location.pointLongitude)
                // 색이 변경되었을 때도 해시가 달라지도록 colorType을 포함
                hasher.combine(location.colorType)
            }
            hasher.combine(visitFrequencyEnabled)
            let newHash = hasher.finalize()
            
            let shouldUpdate = lastLocationsHash != newHash
            
            if shouldUpdate {
                Task { @MainActor in
                    let cellCounts = await caseLocationMarkerManager.updateMarkers(
                        locations,
                        on: mapView,
                        onCellTapped: { [weak self] cellKey in
                            guard let self else { return }
                            Task { @MainActor in
                                let title = self.cellTitle(for: cellKey)
                                parent.onCellMarkerTapped?(cellKey, title)
                            }
                        },
                        onUserLocationTapped: { [weak self] locationId in
                            guard let self else { return }
                            // 사용자 위치 마커 탭 시 Location ID를 전달하여 PlaceInfoSheet 표시
                            parent.onUserLocationMarkerTapped?(locationId)
                        }
                    )

                    if visitFrequencyEnabled {
                        await caseLocationMarkerManager.applyVisitFrequency(with: cellCounts, on: mapView)
                    } else {
                        await caseLocationMarkerManager.resetVisitFrequency(on: mapView)
                    }
                    
                    // 마커 업데이트 완료 후 가시성 재적용
                    caseLocationMarkerManager.setVisibility(isVisible)
                }

                lastLocationsHash = newHash
            } else {
                // 해시가 같아도 가시성은 다시 적용 (줌 레벨 변경 시)
                caseLocationMarkerManager.setVisibility(isVisible)
            }
        }
        
        /// 전달받은 좌표로 네이버 지도 카메라를 이동시킵니다.
        /// - Parameters:
        ///   - coordinate: 이동할 지도 좌표
        ///   - animated: 애니메이션 적용 여부. nil이면 애니메이션을 적용하지 않습니다.
        ///   - duration: 애니메이션 지속 시간 (초). animated가 true일 때만 유효합니다.
        func moveCamera(to coordinate: MapCoordinate, animated: Bool? = nil, duration: Double? = nil) {
            guard let mapView else { return }
            let target = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(target, zoom: defaultZoomLevel))
            if let animated, animated, let duration {
                cameraUpdate.animation = .easeOut
                cameraUpdate.animationDuration = duration
            } else { cameraUpdate.animation = .none }

            mapView.moveCamera(cameraUpdate)
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            guard let bounds = MapBounds(naverBounds: mapView.contentBounds) else { return }
            let zoomLevel = mapView.zoomLevel
            Task { @MainActor in
                parent.onCameraIdle?(bounds, zoomLevel)
            }
        }
        
        @MainActor
        func updateCellLayer(
            cellMarkers: [CellMarker],
            isVisible: Bool,
            on mapView: NMFMapView
        ) {
            let newHash = cellMarkers.map(\.id).hashValue
            
            if lastCellStationsHash != newHash {
                infrastructureManager.updateCellStations(
                    cellMarkers,
                    on: mapView,
                    isVisible: isVisible
                )
                lastCellStationsHash = newHash
            } else { infrastructureManager.setCellVisibility(isVisible) }
        }
        
        @MainActor
        func updateCellRangeOverlay(
            cellMarkers: [CellMarker],
            coverageRange: CoverageRangeType,
            isVisible: Bool,
            on mapView: NMFMapView
        ) {
            let config = CellRangeConfig(
                markerHash: Self.hash(for: cellMarkers),
                coverageRange: coverageRange,
                isVisible: isVisible
            )
            
            guard config != lastCellRangeConfig else { return }
            lastCellRangeConfig = config
            
            Task { [infrastructureManager] in
                await infrastructureManager.updateCellRanges(
                    cellMarkers,
                    coverageRange: coverageRange,
                    isVisible: isVisible,
                    on: mapView
                )
            }
        }
        
        @MainActor
        func updateCCTVLayer(
            cctvMarkers: [CCTVMarker],
            isVisible: Bool,
            on mapView: NMFMapView
        ) {
            let newHash = cctvMarkers.map(\.id).hashValue
            
            if lastCCTVMarkersHash != newHash {
                infrastructureManager.updateCCTVs(
                    cctvMarkers,
                    on: mapView,
                    isVisible: isVisible
                )
                lastCCTVMarkersHash = newHash
            } else { infrastructureManager.setCCTVVisibility(isVisible) }
        }
        
        private struct CellRangeConfig: Equatable {
            let markerHash: Int
            let coverageRange: CoverageRangeType
            let isVisible: Bool
        }
        
        /// 방문 데이터에서 셀 위치만 추출해 기지국 마커 스냅샷으로 변환합니다.
        func makeVisitedCellMarkers(from locations: [Location]) -> [CellMarker] {
            // TAENI : calculator 사용
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
        
        /// 좌표 키에 해당하는 기지국 셀의 주소(CellMarker.location)를 반환합니다.
        private func cellTitle(for cellKey: String) -> String? {
            for marker in parent.cellStations {
                let key = MapCoordinate(latitude: marker.latitude, longitude: marker.longitude).coordinateKey
                if key == cellKey {
                    return marker.location
                }
            }
            return nil
        }
        
        private static func hash(for cellMarkers: [CellMarker]) -> Int {
            var hasher = Hasher()
            for marker in cellMarkers.sorted(by: { $0.id < $1.id }) {
                hasher.combine(marker.id)
                hasher.combine(marker.visitCount)
            }
            return hasher.finalize()
        }
    }
}
