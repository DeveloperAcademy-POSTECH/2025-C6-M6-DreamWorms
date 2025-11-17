//
//  TrackingNaverMapView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import NMapsMap
import SwiftUI

struct TrackingNaverMapView: UIViewRepresentable {
    /// 지도에 표시할 Location (0,1,3 타입만 필터링된 상태로 받음)
    var locations: [Location]
    
    /// 선택된 Location ID 들 (이 ID 들은 강조 표시 + 캡션 노출)
    var selectedLocationIDs: Set<UUID>
    
    /// 마커 탭 콜백 (id, 표시할 이름)
    var onLocationTapped: (UUID, String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        context.coordinator.mapView = mapView
        mapView.positionMode = .normal
        mapView.locationOverlay.hidden = false
        return mapView
    }
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.mapView = uiView
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject {
        var parent: TrackingNaverMapView
        weak var mapView: NMFMapView?
        
        init(parent: TrackingNaverMapView) {
            self.parent = parent
        }
    }
}
