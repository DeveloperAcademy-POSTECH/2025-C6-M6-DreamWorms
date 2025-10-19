//
//  NaverMapOverlayManager.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation
import NMapsMap
import UIKit
import SwiftUI

@MainActor
public struct NaverMapOverlayManager {
    
    // circle
    public static func createCircleOverlay(
        center: CLLocationCoordinate2D,
        radius: Double,
        // TODO: asset 은 internal 이라 임시로 UIColor
        fillColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.15),
        strokeColor: UIColor = UIColor.systemBlue,
        strokeWidth: CGFloat = 2.0
    ) -> NMFCircleOverlay {
        let circle = NMFCircleOverlay()
        circle.center = NMGLatLng(lat: center.latitude, lng: center.longitude)
        circle.radius = radius
        circle.fillColor = fillColor
        circle.outlineColor = strokeColor
        circle.outlineWidth = strokeWidth
        return circle
    }
    
    public static func updateCircleOverlays(
        coordinator: NaverMapCoordinator,
        markers: [NaverMapMarkerData],
        radius: Double,
        show: Bool
    ) {
        coordinator.circleOverlays.values.forEach { $0.mapView = nil }
        coordinator.circleOverlays.removeAll()
        
        guard show else { return }
        
        for marker in markers {
            let circle = createCircleOverlay(
                center: marker.coordinate,
                radius: radius
            )
            circle.mapView = coordinator.mapView
            coordinator.circleOverlays[marker.id] = circle
        }
    }
    
    // MARK: - Path Overlay
    
    public static func createPathOverlay(
        points: [CLLocationCoordinate2D],
        color: UIColor = UIColor.systemBlue,
        width: CGFloat = 5.0,
        outlineColor: UIColor = UIColor.white,
        outlineWidth: CGFloat = 2.0
    ) -> NMFPath {
        let path = NMFPath()
        let nmgPoints = points.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        path.path = NMGLineString(points: nmgPoints)
        path.color = color
        path.width = width
        path.outlineColor = outlineColor
        path.outlineWidth = outlineWidth
        return path
    }
    
    public static func createArrowPathOverlay(
        points: [CLLocationCoordinate2D],
        color: UIColor = UIColor.systemBlue,
        width: CGFloat = 7.0,
        headSizeRatio: CGFloat = 2.0
    ) -> NMFArrowheadPath {
        let path = NMFArrowheadPath()
        let nmgPoints = points.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        path.points = nmgPoints
        path.color = color
        path.width = width
        path.outlineColor = UIColor.white
        path.outlineWidth = 2.0
        path.headSizeRatio = headSizeRatio
        return path
    }
    
    public static func updateFlowPath(
        coordinator: NaverMapCoordinator,
        locations: [NaverMapLocationData],
        showArrows: Bool
    ) {
        // 기존 경로 제거
        coordinator.pathOverlay?.mapView = nil
        coordinator.pathOverlay = nil
        coordinator.arrowPathOverlay?.mapView = nil
        coordinator.arrowPathOverlay = nil
        
        guard locations.count >= 2 else { return }
        
        // 시간순 정렬
        let sortedLocations = locations.sorted { $0.timestamp < $1.timestamp }
        let points = sortedLocations.map { $0.coordinate }
        
        if showArrows {
            // 화살표 경로
            let arrowPath = createArrowPathOverlay(points: points)
            arrowPath.mapView = coordinator.mapView
            coordinator.arrowPathOverlay = arrowPath
        } else {
            // 일반 경로
            let path = createPathOverlay(points: points)
            path.mapView = coordinator.mapView
            coordinator.pathOverlay = path
        }
    }
    
    public static func createPolygonOverlay(
        points: [CLLocationCoordinate2D],
        fillColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.3),
        strokeColor: UIColor = UIColor.systemBlue,
        strokeWidth: CGFloat = 2.0
    ) -> NMFPolygonOverlay {
        let polygon = NMFPolygonOverlay()
        let nmgPoints = points.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        polygon.polygon = NMGPolygon(ring: NMGLineString(points: nmgPoints))
        polygon.fillColor = fillColor
        polygon.outlineColor = strokeColor
        polygon.outlineWidth = UInt(strokeWidth)
        return polygon
    }
    
    // Batch
    public static func removeAllOverlays(coordinator: NaverMapCoordinator) {
        // Circle overlays
        coordinator.circleOverlays.values.forEach { $0.mapView = nil }
        coordinator.circleOverlays.removeAll()
        
        // Path overlays
        coordinator.pathOverlay?.mapView = nil
        coordinator.pathOverlay = nil
        
        // Arrow path overlays
        coordinator.arrowPathOverlay?.mapView = nil
        coordinator.arrowPathOverlay = nil
    }
}
