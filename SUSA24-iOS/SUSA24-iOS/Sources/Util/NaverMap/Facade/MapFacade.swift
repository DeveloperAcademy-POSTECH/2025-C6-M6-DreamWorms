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
/// - Note: Facade가 제공하는 메서드는 실제 사용하는 API만 다루도록 해주세요.
///   단일 메서드가 쓰인다면 Facade에 포함하시고, 조합한 형태의 API가 필요하다면 단일 메서드는 포함하지않습니다.
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
        
        self.cameraController = MapCameraController()
        self.locationController = MapLocationController()
        self.touchHandler = MapTouchHandler()
        self.layerUpdater = MapLayerUpdater(
            infrastructureManager: infrastructureManager,
            caseLocationMarkerManager: caseLocationMarkerManager
        )
        
        cameraController.defaultZoomLevel = MapConstants.defaultZoomLevel
    }
    
    // MARK: - Marker Management
    
    /// 마커 선택 해제를 수행합니다.
    func deselectMarker(on mapView: NMFMapView) async {
        await caseLocationMarkerManager.deselectMarker(on: mapView)
    }
    
    /// Idle 핀을 제거합니다
    func removeIdlePin() async {
        await caseLocationMarkerManager.removeIdlePin()
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
    ///   - zoomLevel: 적용할 줌 레벨. nil이면 현재 줌 레벨을 유지합니다.
    ///   - onCameraMoveConsumed: 카메라 이동 명령 소비 콜백
    ///   - shouldFocusMyLocation: 현위치 포커싱 여부
    ///   - onMyLocationFocusConsumed: 현위치 포커싱 명령 소비 콜백
    ///   - isMapTouchEnabled: 지도 터치 활성화 여부
    ///   - isTimelineSheetPresented: 타임라인 시트 표시 여부
    ///   - isPlaceInfoSheetPresented: PlaceInfoSheet 표시 여부
    ///   - layerData: 레이어 데이터
    ///   - deselectMarkerTrigger: 마커 선택 해제 트리거
    ///   - lastDeselectMarkerTrigger: 마지막 마커 선택 해제 트리거 (inout)
    ///   - onDeselectMarker: 마커 선택 해제 콜백
    ///   - idlePinCoordinate: Idle 핀을 표시할 좌표
    ///   - lastIdlePinCoordinate: 마지막 Idle 핀 좌표 (inout)
    func update(
        mapView: NMFMapView,
        cameraTarget: MapCoordinate?,
        shouldAnimateCamera: Bool,
        zoomLevel: Double? = nil,
        onCameraMoveConsumed: (() -> Void)?,
        shouldFocusMyLocation: Bool,
        onMyLocationFocusConsumed: (() -> Void)?,
        isMapTouchEnabled: Bool,
        isTimelineSheetPresented: Bool,
        isPlaceInfoSheetPresented: Bool,
        layerData: LayerData,
        deselectMarkerTrigger: UUID?,
        lastDeselectMarkerTrigger: inout UUID?,
        onDeselectMarker: @escaping () async -> Void,
        idlePinCoordinate: MapCoordinate?,
        lastIdlePinCoordinate: inout MapCoordinate?
    ) {
        syncComponentStates(mapView: mapView, isMapTouchEnabled: isMapTouchEnabled, isTimelineSheetPresented: isTimelineSheetPresented, isPlaceInfoSheetPresented: isPlaceInfoSheetPresented)
        updateCameraPosition(cameraTarget: cameraTarget, shouldAnimateCamera: shouldAnimateCamera, zoomLevel: zoomLevel, onCameraMoveConsumed: onCameraMoveConsumed)
        focusOnMyLocation(shouldFocusMyLocation: shouldFocusMyLocation, onMyLocationFocusConsumed: onMyLocationFocusConsumed)
        updateAllMarkerLayers(mapView: mapView, layerData: layerData)
        handleDeselectMarkerTrigger(deselectMarkerTrigger: deselectMarkerTrigger, lastDeselectMarkerTrigger: &lastDeselectMarkerTrigger, onDeselectMarker: onDeselectMarker)
        handleIdlePin(idlePinCoordinate: idlePinCoordinate, lastIdlePinCoordinate: &lastIdlePinCoordinate, mapView: mapView)
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

// MARK: - Private Extensions

private extension MapFacade {
    /// 컴포넌트들의 기본 상태를 동기화합니다.
    ///
    /// - mapView를 각 컨트롤러에 할당
    /// - 터치 핸들러의 활성화 상태 및 시트 상태 업데이트
    /// - 시트 상태에 따른 카메라 콘텐츠 패딩 조정
    func syncComponentStates(mapView: NMFMapView, isMapTouchEnabled: Bool, isTimelineSheetPresented: Bool, isPlaceInfoSheetPresented: Bool) {
        cameraController.mapView = mapView
        locationController.mapView = mapView
        
        // 터치 핸들러 상태 업데이트
        touchHandler.isMapTouchEnabled = isMapTouchEnabled
        touchHandler.isTimelineSheetPresented = isTimelineSheetPresented
        touchHandler.isPlaceInfoSheetPresented = isPlaceInfoSheetPresented
        
        // 콘텐츠 패딩 업데이트 (시트 상태에 따라)
        // 둘 다 false면 minimized → inset 0
        // 하나라도 true면 시트가 올라와 있음 → inset 170 적용
        cameraController.updateContentInsetForSheet(isTimelineSheetPresented: isTimelineSheetPresented, isPlaceInfoSheetPresented: isPlaceInfoSheetPresented)
    }
    
    /// 카메라 위치를 업데이트합니다.
    ///
    /// 외부에서 요청한 카메라 이동 명령을 처리합니다.
    /// - `cameraTarget`이 있으면 해당 좌표로 카메라 이동
    /// - 애니메이션 여부에 따라 부드러운 이동 또는 즉시 이동
    /// - 줌 레벨이 지정되면 해당 줌 레벨로 이동, nil이면 현재 줌 레벨 유지
    /// - 이동 완료 후 콜백 호출
    func updateCameraPosition(cameraTarget: MapCoordinate?, shouldAnimateCamera: Bool, zoomLevel: Double? = nil, onCameraMoveConsumed: (() -> Void)?) {
        _ = cameraController.processCameraTarget(
            coordinate: cameraTarget,
            shouldAnimate: shouldAnimateCamera,
            zoomLevel: zoomLevel,
            onConsumed: onCameraMoveConsumed
        )
    }
    
    /// 현위치로 카메라를 포커싱합니다.
    ///
    /// 사용자의 현재 위치를 가져와 해당 위치로 카메라를 이동시킵니다.
    /// - `shouldFocusMyLocation`이 `true`일 때만 실행
    /// - 현재 위치를 가져와 카메라 이동
    /// - 완료 후 콜백 호출
    func focusOnMyLocation(shouldFocusMyLocation: Bool, onMyLocationFocusConsumed: (() -> Void)?) {
        guard shouldFocusMyLocation else { return }
        _ = locationController.focusOnCurrentLocation { [weak self] coordinate in
            guard let self else { return }
            cameraController.moveCamera(to: coordinate, animated: true, duration: MapConstants.cameraAnimationDuration)
        }
        Task { @MainActor in
            onMyLocationFocusConsumed?()
        }
    }
    
    /// 모든 마커 레이어를 업데이트합니다.
    ///
    /// 지도에 표시되는 모든 마커와 오버레이를 업데이트합니다:
    /// - 기지국 셀 마커 레이어 (CellLayer)
    /// - 케이스 위치 마커 레이어 (CaseLocation: home/work/custom/cell)
    /// - 기지국 범위 오버레이 (CellRangeOverlay)
    /// - CCTV 마커 레이어 (CCTVLayer)
    /// - 마커 가시성 상태 동기화
    ///
    /// 줌 레벨에 따라 마커 표시 여부를 자동으로 계산합니다. -> 마커간 중복 레이어 처리하면 변경 예정
    func updateAllMarkerLayers(mapView: NMFMapView, layerData: LayerData) {
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
    }
    
    /// 마커 선택 해제 트리거를 처리합니다.
    ///
    /// PlaceInfoSheet가 닫힐 때 마커 선택을 해제하기 위한 트리거를 처리합니다.
    /// - `deselectMarkerTrigger`가 변경되었는지 확인 (중복 실행 방지)
    /// - 변경되었으면 `onDeselectMarker` 콜백을 호출하여 마커 선택 해제
    /// - `lastDeselectMarkerTrigger`를 업데이트하여 중복 처리 방지
    func handleDeselectMarkerTrigger(
        deselectMarkerTrigger: UUID?,
        lastDeselectMarkerTrigger: inout UUID?,
        onDeselectMarker: @escaping () async -> Void
    ) {
        guard let trigger = deselectMarkerTrigger, trigger != lastDeselectMarkerTrigger else { return }
        
        lastDeselectMarkerTrigger = trigger
        Task { @MainActor in
            await onDeselectMarker()
        }
    }
    
    /// Idle 핀을 표시하거나 제거합니다.
    ///
    /// 빈 공간을 탭했을 때 표시되는 임시 핀(Idle 핀)을 관리합니다.
    /// - `idlePinCoordinate`가 변경되었는지 확인 (중복 실행 방지)
    /// - 좌표가 있으면 해당 위치에 Idle 핀 표시
    /// - 좌표가 `nil`이면 Idle 핀 제거
    /// - `lastIdlePinCoordinate`를 업데이트하여 중복 처리 방지
    func handleIdlePin(
        idlePinCoordinate: MapCoordinate?,
        lastIdlePinCoordinate: inout MapCoordinate?,
        mapView: NMFMapView
    ) {
        guard idlePinCoordinate != lastIdlePinCoordinate else { return }
        lastIdlePinCoordinate = idlePinCoordinate
        if let coordinate = idlePinCoordinate {
            Task { @MainActor in
                await caseLocationMarkerManager.makeIdlePin(at: coordinate, on: mapView)
            }
        } else {
            Task { @MainActor in
                await self.removeIdlePin()
            }
        }
    }
}
