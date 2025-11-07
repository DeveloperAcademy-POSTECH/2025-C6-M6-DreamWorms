//
//  NaverMapView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import NMapsMap
import SwiftUI

struct NaverMapView: UIViewRepresentable {
    var onMapTapped: ((NMGLatLng) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.touchDelegate = context.coordinator
        return mapView
    }

    func updateUIView(_: NMFMapView, context _: Context) {}
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate {
        let parent: NaverMapView
        
        init(parent: NaverMapView) {
            self.parent = parent
        }
        
        func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
            parent.onMapTapped?(latlng)
        }
    }
}

// MARK: - Extension Method

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
