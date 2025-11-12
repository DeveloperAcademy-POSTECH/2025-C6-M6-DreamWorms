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
    /// 외부 모듈이 현위치를 포커싱해야 함을 알리는 플래그입니다.
    var shouldFocusMyLocation: Bool = false
    
    // MARK: 명령 처리 결과 콜백
    
    /// 카메라 이동 명령을 소비했음을 상위 모듈에 알리는 콜백입니다.
    var onCameraMoveConsumed: (() -> Void)?
    /// 현위치 포커싱 명령을 소비했음을 상위 모듈에 알리는 콜백입니다.
    var onMyLocationFocusConsumed: (() -> Void)?
    
    // MARK: 사용자 상호작용 콜백
    
    /// 지도 터치 이벤트를 상위 모듈로 전달하는 콜백입니다.
    var onMapTapped: ((NMGLatLng) -> Void)?
    /// 기지국 데이터
    var cellStations: [CellStation] = []
    /// 기지국 레이어 표시 여부
    var isCellLayerEnabled: Bool = false
    
    // MARK: - Dependencies
    
    /// 인프라 마커 관리자
    let infrastructureManager: InfrastructureMarkerManager
    
    // MARK: - UIViewRepresentable
    
    /// 네이버 지도 컨트롤을 관리할 코디네이터를 생성합니다.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, infrastructureManager: infrastructureManager)
    }
    
    /// 네이버 지도 뷰를 생성하고 초기 설정을 수행합니다.
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.touchDelegate = context.coordinator
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
            context.coordinator.moveCamera(to: coordinate)
            Task { @MainActor in
                onCameraMoveConsumed?()
            }
        } else if cameraTargetCoordinate == nil {
            context.coordinator.lastCameraTarget = nil
        }
        
        // 2) 현위치 포커싱 명령 적용
        if shouldFocusMyLocation {
            _ = context.coordinator.focusCameraOnMyLocation()
            Task { @MainActor in
                onMyLocationFocusConsumed?()
            }
        }
        
        // 3) 레이어 업데이트
        context.coordinator.updateCellLayer(
            cellStations: cellStations,
            isVisible: isCellLayerEnabled,
            on: uiView
        )
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate {
        /// 네이버 지도 뷰 인스턴스에 대한 약한 참조입니다.
        weak var mapView: NMFMapView?
        let parent: NaverMapView
        
        var lastCameraTarget: MapCoordinate?
        var defaultZoomLevel: Double = 15
        
        private let infrastructureManager: InfrastructureMarkerManager
        private var lastCellStationsHash: Int?

        init(parent: NaverMapView, infrastructureManager: InfrastructureMarkerManager) {
            self.parent = parent
            self.infrastructureManager = infrastructureManager
        }
        
        /// 지도 터치 이벤트를 SwiftUI 상위 모듈로 전달합니다.
        func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
            parent.onMapTapped?(latlng)
        }
        
        /// 전달받은 좌표로 네이버 지도 카메라를 이동시킵니다.
        /// - Parameter coordinate: 이동할 지도 좌표
        func moveCamera(to coordinate: MapCoordinate) {
            guard let mapView else { return }
            let target = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(target, zoom: defaultZoomLevel))
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            mapView.moveCamera(cameraUpdate)
        }
        
        /// 네이버 지도에서 제공하는 위치 추적 정보를 이용해 현위치로 카메라를 이동합니다.
        /// - Returns: 위치 정보를 활용해 카메라 이동을 수행했다면 `true`, 아니면 `false`를 반환합니다.
        func focusCameraOnMyLocation() -> Bool {
            guard let mapView else { return false }
            mapView.positionMode = .normal
            let overlay = mapView.locationOverlay
            guard overlay.hidden == false else { return false }
            let currentLocation = overlay.location
            let coordinate = MapCoordinate(latitude: currentLocation.lat, longitude: currentLocation.lng)
            moveCamera(to: coordinate)
            return true
        }
        
        @MainActor
        func updateCellLayer(
            cellStations: [CellStation],
            isVisible: Bool,
            on mapView: NMFMapView
        ) {
            let newHash = cellStations.map(\.id).hashValue
            
            if lastCellStationsHash != newHash {
                infrastructureManager.updateCellStations(
                    cellStations,
                    on: mapView,
                    isVisible: isVisible
                )
                lastCellStationsHash = newHash
            } else {
                infrastructureManager.setCellVisibility(isVisible)
            }
        }
    }
}

// MARK: - NMGLatLng Extension

extension NMGLatLng {
    /// 네이버 지도 좌표를 카카오 API 요청 DTO로 변환합니다.
    /// - Note: 네이버 지도는 (위도, 경도) 순서이지만, 카카오 API는 (경도, 위도) 순서를 사용합니다.
    /// - Parameter inputCoord: 입력 좌표계 (기본값: WGS84)
    /// - Returns: 카카오 API 요청 DTO
    func toKakaoRequestDTO(inputCoord: String? = "WGS84") -> KakaoCoordToLocationRequestDTO {
        KakaoCoordToLocationRequestDTO(
            x: String(lng), // 경도 (네이버 lng → 카카오 x)
            y: String(lat), // 위도 (네이버 lat → 카카오 y)
            inputCoord: inputCoord
        )
    }
}
