//
//  NaverMapMarkerManager.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation
import NMapsMap
import UIKit
import SwiftUI

@MainActor
public struct NaverMapMarkerManager {
    
    public static func createMarker(
        from data: NaverMapMarkerData,
        onTap: @escaping (NaverMapMarkerData) -> Void
    ) -> NMFMarker {
        let marker = NMFMarker()
        
        marker.position = NMGLatLng(
            lat: data.coordinate.latitude,
            lng: data.coordinate.longitude
        )
        
        configureMarkerIcon(marker, data: data)
        configureCaptions(marker, data: data)
        
        marker.touchHandler = { [data] _ in
            onTap(data)
            return true
        }
        
        // 충돌 처리
        marker.isHideCollidedSymbols = true
        marker.isHideCollidedMarkers = true
        
        // TODO: 클러스터링 됐을 때 아이콘 어떤거 보여줄지 설정
        //        marker.isForceShowIcon = data.markerType.forceShowIcon
        
        return marker
    }
    
    private static func configureMarkerIcon(_ marker: NMFMarker, data: NaverMapMarkerData) {
        let iconType: MarkerIconType
        
        switch data.markerType {
        case .frequency:
            iconType = .number(
                data.frequency,
                textColor: .white,
                background: .mainBlue,
                stroke: .white
            )
            
            // TODO: SF Symbol 변수 타입 처리 필요
            // 위치 정보의 타입에 따라 값을 가져오게 추후 변경
        case .uniqueLocations, .timeSequence, .flow:
            iconType = .symbol(
                name: "dot.radiowaves.left.and.right",
                color: .white,
                background: .mainBlue,
                stroke: .white,
                width: 12,
                height: 10
            )
        }
        
        if let iconImage = NaverMapMarkerIconFactory.create(iconType) {
            marker.iconImage = iconImage
        }
        
        marker.anchor = CGPoint(x: 0.5, y: 0.5)
        marker.alpha = 1.0
    }
    
    private static func configureCaptions(_ marker: NMFMarker, data: NaverMapMarkerData) {
        marker.captionText = data.title
        marker.captionTextSize = 12
        marker.captionColor = UIColor.systemGray
        marker.captionHaloColor = UIColor.systemBackground
        
        if let sequenceText = data.sequenceText {
            marker.subCaptionText = sequenceText
            marker.subCaptionTextSize = 10
            marker.subCaptionColor = UIColor.systemGreen
            marker.subCaptionHaloColor = UIColor.systemBackground
        }
        
        marker.captionOffset = 10
    }
    
    public static func updateMarkers(
        coordinator: NaverMapCoordinator,
        markers newMarkers: [NaverMapMarkerData],
        onMarkerTap: @escaping (NaverMapMarkerData) -> Void
    ) {
        coordinator.markers.values.forEach { $0.mapView = nil }
        coordinator.markers.removeAll()
        
        for markerData in newMarkers {
            let marker = createMarker(from: markerData, onTap: onMarkerTap)
            marker.mapView = coordinator.mapView
            coordinator.markers[markerData.id] = marker
        }
    }
    
    public static func showMarkers(_ markers: [UUID: NMFMarker], mapView: NMFMapView?) {
        markers.values.forEach { $0.mapView = mapView }
    }
    
    public static func hideMarkers(_ markers: [UUID: NMFMarker]) {
        markers.values.forEach { $0.mapView = nil }
    }
    
    public static func removeAllMarkers(_ markers: inout [UUID: NMFMarker]) {
        hideMarkers(markers)
        markers.removeAll()
    }
    
    public static func animateMarker(
        _ marker: NMFMarker,
        to position: NMGLatLng,
        duration: TimeInterval = 0.3
    ) {
        UIView.animate(withDuration: duration) {
            marker.position = position
        }
    }
    
    public static func pulseMarker(_ marker: NMFMarker) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.repeat, .autoreverse],
            animations: {
                marker.alpha = 0.5
            },
            completion: { _ in
                marker.alpha = 1.0
            }
        )
    }
}
