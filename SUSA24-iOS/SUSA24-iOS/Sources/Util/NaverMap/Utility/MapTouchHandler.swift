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
    
    /// 타임라인 시트의 표시 상태입니다.
    /// - `true`: 타임라인 시트가 표시됨 (올라와 있음)
    /// - `false`: 타임라인 시트가 닫힘 (최소화됨)
    var isTimelineSheetPresented: Bool = false
    
    /// PlaceInfoSheet의 표시 상태입니다.
    /// - `true`: PlaceInfoSheet가 표시됨
    /// - `false`: PlaceInfoSheet가 닫힘
    var isPlaceInfoSheetPresented: Bool = false
    
    /// 맵 터치 콜백
    var onMapTapped: ((NMGLatLng) -> Void)?
    
    /// 마커 선택 해제 콜백
    var onMarkerDeselect: (() async -> Void)?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Touch Event Handling
    
    /// 맵 터치 이벤트를 처리합니다.
    /// - Parameter latlng: 터치한 위치의 좌표
    /// - Note: 모든 맵 터치를 MapFeature로 전달합니다.
    ///         MapFeature에서 PlaceInfoSheet 상태에 따라 콘텐츠만 업데이트할지 새로 열지 결정합니다.
    func handleMapTap(latlng: NMGLatLng) {
        // 지도 터치가 비활성화되어 있으면 이벤트를 처리하지 않습니다.
        guard isMapTouchEnabled else { return }
        
        // 마커 선택 해제
        Task { @MainActor in
            await onMarkerDeselect?()
        }
        
        // PlaceInfoSheet가 열려있지 않을 때만 타임라인 시트를 최소 높이로 내리도록 요청
        // (PlaceInfoSheet가 열려있으면 콘텐츠만 업데이트하므로 타임라인은 유지)
        if !isPlaceInfoSheetPresented {
            NotificationCenter.default.post(name: .resetDetentToShort, object: nil)
        }
        
        // PlaceInfoSheet 표시를 위한 콜백 호출
        onMapTapped?(latlng)
    }
}
