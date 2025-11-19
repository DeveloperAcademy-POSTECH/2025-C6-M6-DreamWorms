//
//  NaverMapView.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//

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
        
        let layerData = MapFacade.LayerData(
            cellStations: cellStations,
            locations: locations,
            cctvMarkers: cctvMarkers,
            isCellLayerEnabled: isCellLayerEnabled,
            isCCTVLayerEnabled: isCCTVLayerEnabled,
            isVisitFrequencyEnabled: isVisitFrequencyEnabled,
            isCellRangeVisible: isCellRangeVisible,
            cellCoverageRange: cellCoverageRange
        )

        context.coordinator.facade.update(
            mapView: uiView,
            cameraTarget: cameraTargetCoordinate,
            shouldAnimateCamera: shouldAnimateCameraTarget,
            onCameraMoveConsumed: onCameraMoveConsumed,
            shouldFocusMyLocation: shouldFocusMyLocation,
            onMyLocationFocusConsumed: onMyLocationFocusConsumed,
            isMapTouchEnabled: isMapTouchEnabled,
            isTimelineSheetMinimized: isTimelineSheetMinimized,
            layerData: layerData,
            deselectMarkerTrigger: deselectMarkerTrigger,
            lastDeselectMarkerTrigger: &context.coordinator.lastDeselectMarkerTrigger,
            onDeselectMarker: { await context.coordinator.facade.deselectMarker(on: uiView) }
        )
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        /// 네이버 지도 뷰 인스턴스에 대한 약한 참조입니다.
        weak var mapView: NMFMapView?
        let parent: NaverMapView
        
        /// 맵을 담당하는 Facade
        let facade: MapFacade
        
        var lastDeselectMarkerTrigger: UUID?

        init(
            parent: NaverMapView,
            infrastructureManager: InfrastructureMarkerManager,
            caseLocationMarkerManager: CaseLocationMarkerManager
        ) {
            self.parent = parent
            
            // Facade가 모든 컴포넌트를 생성하고 관리
            self.facade = MapFacade(
                infrastructureManager: infrastructureManager,
                caseLocationMarkerManager: caseLocationMarkerManager
            )
            
            super.init()
            
            // Facade에 콜백 설정 (parent 참조 필요)
            facade.configureCallbacks(
                onCameraIdle: { [weak self] bounds, zoomLevel in
                    self?.parent.onCameraIdle?(bounds, zoomLevel)
                },
                onInitialLocation: { _ in
                    // NOTE: 초기 설정 관리 위치 고민 중
                    // 초기 위치는 Facade 내부에서 카메라 이동 처리
                },
                onMapTapped: { [weak self] latlng in
                    self?.parent.onMapTapped?(latlng)
                },
                onMarkerDeselect: { [weak self] in
                    guard let self, let mapView else { return }
                    await facade.deselectMarker(on: mapView)
                },
                onCellMarkerTapped: { [weak self] (cellKey: String, _: String?) in
                    guard let self else { return }
                    Task { @MainActor in
                        let title = MapDataService.findCellTitle(by: cellKey, in: self.parent.cellStations)
                        self.parent.onCellMarkerTapped?(cellKey, title)
                    }
                },
                onUserLocationMarkerTapped: { [weak self] locationId in
                    guard let self else { return }
                    self.parent.onUserLocationMarkerTapped?(locationId)
                }
            )
        }
        
        // MARK: - Delegate Methods
        
        /// 지도 터치 이벤트를 Facade를 통해 처리합니다.
        func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
            facade.handleMapTap(latlng: latlng)
        }
        
        /// 카메라 이동 완료 이벤트를 Facade를 통해 처리합니다.
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            facade.handleCameraIdle(mapView)
        }
    }
}
