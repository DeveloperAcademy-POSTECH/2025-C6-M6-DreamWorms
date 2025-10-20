//
//  NaverMapOverlayManager.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation
import NMapsMap
import CoreLocation
import UIKit

enum NaverMapOverlayManager {
    
    static func updateGradientCircleOverlays(
        coordinator: NaverMapCoordinator,
        markers: [NaverMapMarkerData],
        radiusPresets: Set<RadiusPreset>,
        show: Bool
    ) {
        coordinator.clearGroundOverlays()
        
        guard show, !markers.isEmpty, !radiusPresets.isEmpty else {
            return
        }
        
        let sortedPresets = radiusPresets.sorted { $0.meters > $1.meters }
        
        for marker in markers {
            for preset in sortedPresets {
                let gradientImage = createGradientImage(for: preset)
                
                let bounds = calculateBounds(
                    center: marker.coordinate,
                    radiusMeters: preset.meters
                )
                
                let overlay = NMFGroundOverlay(
                    bounds: bounds,
                    image: NMFOverlayImage(image: gradientImage)
                )
                
                overlay.mapView = coordinator.mapView
                coordinator.groundOverlays.append(overlay)
            }
        }
    }
    
    private static func createGradientImage(for preset: RadiusPreset) -> UIImage {
        let color = preset.color
        let backgroundColor = color.withAlphaComponent(0.0)
        
        let stops = [
            GradientImageGenerator.GradientStop(
                color: color,
                location: 0.0
            ),
            GradientImageGenerator.GradientStop(
                color: color.withAlphaComponent(preset.fillAlpha),
                location: 0.94
            ),
            GradientImageGenerator.GradientStop(
                color: color.withAlphaComponent(0.0),
                location: 1.0
            )
        ]
        
        return GradientImageGenerator.createRadialGradientImage(
            size: CGSize(width: 512, height: 512),
            backgroundColor: backgroundColor,
            stops: stops
        )
    }
    
    static func updateCircleOverlays(
        coordinator: NaverMapCoordinator,
        markers: [NaverMapMarkerData],
        radiusPresets: Set<RadiusPreset>,
        show: Bool
    ) {
        coordinator.clearCircleOverlays()
        
        guard show, !markers.isEmpty, !radiusPresets.isEmpty else {
            return
        }
        
        let sortedPresets = radiusPresets.sorted { $0.meters > $1.meters }
        
        for marker in markers {
            for preset in sortedPresets {
                let circle = NMFCircleOverlay()
                circle.center = NMGLatLng(
                    lat: marker.coordinate.latitude,
                    lng: marker.coordinate.longitude
                )
                circle.radius = preset.meters
                // TODO: 선이므로 fill 채우지않음
                // 강제로 흰색 outline
                circle.fillColor = preset.color.withAlphaComponent(0.0)
                circle.outlineColor = .white
                circle.outlineWidth = 0.5
                circle.mapView = coordinator.mapView
                
                coordinator.circleOverlays.append(circle)
            }
        }
    }
    
    // MARK: - Flow Path
    
    static func updateFlowPath(
        coordinator: NaverMapCoordinator,
        locations: [NaverMapLocationData],
        showArrows: Bool
    ) {
        coordinator.pathOverlay?.mapView = nil
        coordinator.pathOverlay = nil
        coordinator.arrowPathOverlay?.mapView = nil
        coordinator.arrowPathOverlay = nil
        
        guard locations.count >= 2 else {
            return
        }
        
        let sortedLocations = locations.sorted { $0.timestamp < $1.timestamp }
        let points = sortedLocations.map { location in
            NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
        
        if showArrows {
            let arrowPath = NMFArrowheadPath()
            arrowPath.points = points
            arrowPath.color = UIColor.systemIndigo
            arrowPath.outlineColor = UIColor.white
            arrowPath.width = 7
            arrowPath.outlineWidth = 2
            arrowPath.headSizeRatio = 2.5
            arrowPath.mapView = coordinator.mapView
            
            coordinator.arrowPathOverlay = arrowPath
        } else {
            let path = NMFPath()
            path.path = NMGLineString(points: points)
            path.color = UIColor.systemIndigo
            path.outlineColor = UIColor.white
            path.width = 7
            path.outlineWidth = 2
            path.mapView = coordinator.mapView
            
            coordinator.pathOverlay = path
        }
    }
    
    // MARK: - Helper
    
    private static func calculateBounds(
        center: CLLocationCoordinate2D,
        radiusMeters: Double
    ) -> NMGLatLngBounds {
        let latitudeDelta = radiusMeters / 111000.0
        let longitudeDelta = radiusMeters / (111000.0 * cos(center.latitude * .pi / 180.0))
        
        let southWest = NMGLatLng(
            lat: center.latitude - latitudeDelta,
            lng: center.longitude - longitudeDelta
        )
        
        let northEast = NMGLatLng(
            lat: center.latitude + latitudeDelta,
            lng: center.longitude + longitudeDelta
        )
        
        return NMGLatLngBounds(southWest: southWest, northEast: northEast)
    }
}

final class GradientImageGenerator {
    
    struct GradientStop {
        let color: UIColor
        let location: CGFloat
        
        init(color: UIColor, location: CGFloat) {
            self.color = color
            self.location = location
        }
    }
    
    private static var cache: [String: UIImage] = [:]
    
    static func createRadialGradientImage(
        size: CGSize,
        backgroundColor: UIColor? = nil,
        stops: [GradientStop]
    ) -> UIImage {
        let cacheKey = generateCacheKey(size: size, backgroundColor: backgroundColor, stops: stops)
        
        if let cached = cache[cacheKey] {
            return cached
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            if let bgColor = backgroundColor {
                cgContext.setFillColor(bgColor.cgColor)
                cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            }
            
            guard let gradient = createGradient(stops: stops) else { return }
            
            cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
        
        cache[cacheKey] = image
        return image
    }
    
    private static func createGradient(stops: [GradientStop]) -> CGGradient? {
        guard stops.count >= 2 else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colors = stops.map { $0.color.cgColor } as CFArray
        let locations = stops.map { $0.location }
        
        return CGGradient(
            colorsSpace: colorSpace,
            colors: colors,
            locations: locations
        )
    }
    
    private static func generateCacheKey(size: CGSize, backgroundColor: UIColor?, stops: [GradientStop]) -> String {
        let bgKey = backgroundColor?.toHexString() ?? "none"
        
        let stopsKey = stops.map { stop in
            let hex = stop.color.toHexString()
            return "\(hex)_\(stop.location)"
        }.joined(separator: "_")
        
        return "\(Int(size.width))x\(Int(size.height))_\(bgKey)_\(stopsKey)"
    }
    
    static func clearCache() {
        cache.removeAll()
    }
}

private extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255)
        let alpha = Int(a * 100)
        return String(format: "%06x_%d", rgb, alpha)
    }
}
