//
//  NaverMapView.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//
//

import NMapsMap
import SwiftUI

/// SwiftUI에서 네이버 지도 SDK(`NMFMapView`)를 사용하기 위한 래퍼 뷰입니다.
/// 외부에서 전달된 좌표 명령을 적용하고, 지도 터치 이벤트를 다시 SwiftUI로 전달합니다.
struct NaverMapView: UIViewRepresentable {
    /// 지도 카메라가 이동해야 할 목표 좌표입니다. 값이 바뀔 때마다 카메라를 이동합니다.
    var targetCoordinate: MapCoordinate?
    /// 카메라 이동을 했다는 사실을 상위 모듈에 알리는 콜백입니다.
    var onMoveConsumed: (() -> Void)?
    /// 지도 터치 이벤트를 상위 모듈로 전달하는 콜백입니다.
    var onMapTapped: ((NMGLatLng) -> Void)?
    
    /// 네이버 지도 컨트롤을 관리할 코디네이터를 생성합니다.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// 네이버 지도 뷰를 생성하고 초기 설정을 수행합니다.
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.touchDelegate = context.coordinator
        context.coordinator.mapView = mapView
        return mapView
    }

    /// SwiftUI 상태에 맞게 네이버 지도 뷰를 갱신합니다.
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        context.coordinator.mapView = uiView
        if let coordinate = targetCoordinate, context.coordinator.lastCoordinate != coordinate {
            context.coordinator.lastCoordinate = coordinate
            context.coordinator.moveCamera(to: coordinate)
            Task { @MainActor in
                onMoveConsumed?()
            }
        }
    }
    
    /// 네이버 지도와 SwiftUI 사이의 이벤트를 중계하는 객체입니다.
    class Coordinator: NSObject, NMFMapViewTouchDelegate {
        /// 네이버 지도 뷰 인스턴스에 대한 약한 참조입니다.
        var mapView: NMFMapView?
        /// 가장 최근에 적용한 좌표를 저장해 중복 명령을 방지합니다.
        var lastCoordinate: MapCoordinate?
        /// SwiftUI `UIViewRepresentable` 래퍼의 참조입니다.
        let parent: NaverMapView
    
        var defaultZoomLevel: Double = 15

        init(parent: NaverMapView) {
            self.parent = parent
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
            let cameraPosition = NMFCameraPosition(
                target,
                zoom: defaultZoomLevel,
                tilt: mapView.cameraPosition.tilt,
                heading: mapView.cameraPosition.heading
            )
            let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            mapView.moveCamera(cameraUpdate)
        }
    }
}

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
