//
//  MapFacade.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/25/25.
//

import NMapsMap

/// 맵을 위한 Facade
/// - 복잡한 서브시스템(카메라, 위치, 레이어, 터치)을 단순한 인터페이스로 제공
/// - 모든 컴포넌트를 생성하고 관리하며, 업데이트 로직을 전담
@MainActor
final class MapFacade {
    // MARK: - Dependencies
    
    private let infrastructureManager: InfrastructureMarkerManager
    private let caseLocationMarkerManager: CaseLocationMarkerManager
    
    // MARK: - Components
    
    private let cameraController: MapCameraController
    private let locationController: MapLocationController
    private let touchHandler: MapTouchHandler
    private let layerUpdater: MapLayerUpdater
    
    // MARK: - Initialization
    
    init(
        infrastructureManager: InfrastructureMarkerManager,
        caseLocationMarkerManager: CaseLocationMarkerManager
    ) {
        self.infrastructureManager = infrastructureManager
        self.caseLocationMarkerManager = caseLocationMarkerManager
        
        // Facade가 모든 컴포넌트 생성
        self.cameraController = MapCameraController()
        self.locationController = MapLocationController()
        self.touchHandler = MapTouchHandler()
        self.layerUpdater = MapLayerUpdater(
            infrastructureManager: infrastructureManager,
            caseLocationMarkerManager: caseLocationMarkerManager
        )
        
        // 기본 설정
        cameraController.defaultZoomLevel = MapConstants.defaultZoomLevel
    }
    
    // MARK: - Marker Management
    
    /// 마커 선택 해제를 수행합니다.
    @MainActor
    func deselectMarker(on mapView: NMFMapView) async {
        await caseLocationMarkerManager.deselectMarker(on: mapView)
    }
    
    // MARK: - Callback Configuration
    
    /// 콜백을 설정합니다. Coordinator에서 호출하여 parent 참조를 전달합니다.
    func configureCallbacks(
        onCameraIdle: @escaping (MapBounds, Double) -> Void,
        onInitialLocation: @escaping (MapCoordinate) -> Void,
        onMapTapped: @escaping (NMGLatLng) -> Void,
        onMarkerDeselect: @escaping () async -> Void,
        onCellMarkerTapped: @escaping (String, String?) -> Void,
        onUserLocationMarkerTapped: @escaping (UUID) -> Void
    ) {
        cameraController.onCameraIdle = onCameraIdle
        
        locationController.onInitialLocation = { [weak self] coordinate in
            onInitialLocation(coordinate)
            // 초기 위치 설정 시 카메라 이동
            self?.cameraController.moveCamera(to: coordinate)
        }
        
        touchHandler.onMapTapped = onMapTapped
        touchHandler.onMarkerDeselect = onMarkerDeselect
        
        layerUpdater.onCellMarkerTapped = onCellMarkerTapped
        layerUpdater.onUserLocationMarkerTapped = onUserLocationMarkerTapped
    }
    
    // MARK: - Facade Methods
    
    /// 맵 뷰와 모든 컴포넌트를 업데이트합니다.
    /// - Parameters:
    ///   - mapView: 네이버 지도 뷰
    ///   - cameraTarget: 카메라 이동 목표 좌표
    ///   - shouldAnimateCamera: 카메라 이동 애니메이션 여부
    ///   - onCameraMoveConsumed: 카메라 이동 명령 소비 콜백
    ///   - shouldFocusMyLocation: 현위치 포커싱 여부
    ///   - onMyLocationFocusConsumed: 현위치 포커싱 명령 소비 콜백
    ///   - isMapTouchEnabled: 지도 터치 활성화 여부
    ///   - isTimelineSheetMinimized: 타임라인 시트 최소화 여부
    ///   - layerData: 레이어 데이터
    ///   - deselectMarkerTrigger: 마커 선택 해제 트리거
    ///   - lastDeselectMarkerTrigger: 마지막 마커 선택 해제 트리거 (inout)
    ///   - onDeselectMarker: 마커 선택 해제 콜백
    func update(
        mapView: NMFMapView,
        cameraTarget: MapCoordinate?,
        shouldAnimateCamera: Bool,
        onCameraMoveConsumed: (() -> Void)?,
        shouldFocusMyLocation: Bool,
        onMyLocationFocusConsumed: (() -> Void)?,
        isMapTouchEnabled: Bool,
        isTimelineSheetMinimized: Bool,
        layerData: LayerData,
        deselectMarkerTrigger: UUID?,
        lastDeselectMarkerTrigger: inout UUID?,
        onDeselectMarker: @escaping () async -> Void
    ) {
        // 1) 의존성 주입
        cameraController.mapView = mapView
        locationController.mapView = mapView
        
        // 2) 터치 핸들러 상태 업데이트
        touchHandler.isMapTouchEnabled = isMapTouchEnabled
        touchHandler.isTimelineSheetMinimized = isTimelineSheetMinimized
        
        // 3) 카메라 이동 명령 처리
        _ = cameraController.processCameraTarget(
            coordinate: cameraTarget,
            shouldAnimate: shouldAnimateCamera,
            onConsumed: onCameraMoveConsumed
        )
        
        // 4) 현위치 포커싱 명령 처리
        if shouldFocusMyLocation {
            let success = locationController.focusOnCurrentLocation { [weak self] coordinate in
                guard let self else { return }
                cameraController.moveCamera(to: coordinate, animated: true, duration: MapConstants.cameraAnimationDuration)
            }
            Task { @MainActor in
                onMyLocationFocusConsumed?()
            }
        }
        
        // 5) 레이어 업데이트
        let zoomLevel = mapView.zoomLevel
        let shouldShowMarkers = zoomLevel > MapConstants.markerVisibilityThreshold
        let cellLayerVisible = shouldShowMarkers && layerData.isCellLayerEnabled
        let cctvLayerVisible = shouldShowMarkers && layerData.isCCTVLayerEnabled
        
        layerUpdater.updateCellLayer(
            cellMarkers: layerData.cellStations,
            isVisible: cellLayerVisible,
            on: mapView
        )
        layerUpdater.updateCaseLocations(
            locations: layerData.locations,
            visitFrequencyEnabled: layerData.isVisitFrequencyEnabled,
            isVisible: true, // caseLocation 마커는 줌 레벨과 무관하게 항상 표시
            zoomLevel: zoomLevel,
            on: mapView
        )
        layerUpdater.updateCellRangeOverlay(
            cellMarkers: MapDataService.makeVisitedCellMarkers(from: layerData.locations),
            coverageRange: layerData.cellCoverageRange,
            isVisible: layerData.isCellRangeVisible,
            on: mapView
        )
        layerUpdater.updateCCTVLayer(
            cctvMarkers: layerData.cctvMarkers,
            isVisible: cctvLayerVisible,
            on: mapView
        )
        layerUpdater.updateMarkerVisibility(
            isCaseLocationVisible: true, // caseLocation 마커는 줌 레벨과 무관하게 항상 표시
            isCellMarkerVisible: cellLayerVisible,
            isCCTVVisible: cctvLayerVisible
        )
        
        // 6) 마커 선택 해제 트리거 처리
        if let trigger = deselectMarkerTrigger, trigger != lastDeselectMarkerTrigger {
            lastDeselectMarkerTrigger = trigger
            Task { @MainActor in
                await onDeselectMarker()
            }
        }
    }
    
    // MARK: - Component Access (for Delegate Methods)
    
    /// 카메라 컨트롤러에 접근합니다. (Delegate 메서드에서 사용)
    func handleCameraIdle(_ mapView: NMFMapView) {
        cameraController.handleCameraIdle(mapView)
    }
    
    /// 터치 핸들러에 접근합니다. (Delegate 메서드에서 사용)
    func handleMapTap(latlng: NMGLatLng) {
        touchHandler.handleMapTap(latlng: latlng)
    }
    
    // MARK: - Data Types
    
    /// 레이어 업데이트에 필요한 데이터
    struct LayerData {
        let cellStations: [CellMarker]
        let locations: [Location]
        let cctvMarkers: [CCTVMarker]
        let isCellLayerEnabled: Bool
        let isCCTVLayerEnabled: Bool
        let isVisitFrequencyEnabled: Bool
        let isCellRangeVisible: Bool
        let cellCoverageRange: CoverageRangeType
    }
}
