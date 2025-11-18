//
//  MapTouchHandler.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/25/25.
//

import Foundation
import NMapsMap

/// 맵 터치 이벤트 처리를 담당하는 핸들러
@MainActor
final class MapTouchHandler {
    // MARK: - Properties
    
    /// 지도 터치 활성화 여부
    var isMapTouchEnabled: Bool = true
    
    /// 타임라인 시트가 최소 높이인지 여부
    var isTimelineSheetMinimized: Bool = true
    
    /// 맵 터치 콜백
    var onMapTapped: ((NMGLatLng) -> Void)?
    
    /// 마커 선택 해제 콜백
    var onMarkerDeselect: (() async -> Void)?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Touch Event Handling
    
    /// 맵 터치 이벤트를 처리합니다.
    /// - Parameter latlng: 터치한 위치의 좌표
    func handleMapTap(latlng: NMGLatLng) {
        // 지도 터치가 비활성화되어 있으면 이벤트를 처리하지 않습니다.
        guard isMapTouchEnabled else { return }
        
        // 마커 선택 해제
        Task { @MainActor in
            await onMarkerDeselect?()
        }
        
        // 타임라인 시트를 최소 높이로 내리도록 요청 (detent 제어)
        NotificationCenter.default.post(name: .resetDetentToShort, object: nil)
        
        // 타임라인 시트가 올라와 있으면 PlaceInfoSheet 표시 안 함
        guard isTimelineSheetMinimized else { return }
        
        // PlaceInfoSheet 표시를 위한 콜백 호출
        onMapTapped?(latlng)
    }
}
