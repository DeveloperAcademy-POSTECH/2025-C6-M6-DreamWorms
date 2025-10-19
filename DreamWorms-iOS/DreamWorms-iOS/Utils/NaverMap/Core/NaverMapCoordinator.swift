//
//  NaverMapCoordinator.swift
//  DreamWorms-iOS
//

import CoreLocation
import Foundation
import NMapsMap
import SwiftUI

@MainActor
public final class NaverMapCoordinator: NSObject {
    let parent: NaverMapView
    
    var mapView: NMFMapView?
    var markers: [UUID: NMFMarker] = [:]
    var circleOverlays: [UUID: NMFCircleOverlay] = [:]
    var pathOverlay: NMFPath?
    var arrowPathOverlay: NMFArrowheadPath?
    
    var lastCameraPosition: NMFCameraPosition?
    
    // 클러스터링
    var clusterer: NMCClusterer<ClusterItemKey>?
    var autoClusteringEnabled = true
    
    init(_ parent: NaverMapView) {
        self.parent = parent
        super.init()
    }
    
    func setupMapView(_ mapView: NMFMapView) {
        self.mapView = mapView
        mapView.addCameraDelegate(delegate: self)
        mapView.touchDelegate = self
        
        applyConfiguration(parent.configuration)
        
        let initialCamera = parent.cameraPosition ?? NMFCameraPosition(
            NMGLatLng(
                lat: parent.configuration.initialPosition.latitude,
                lng: parent.configuration.initialPosition.longitude
            ),
            zoom: parent.configuration.initialZoom
        )
        mapView.moveCamera(NMFCameraUpdate(position: initialCamera))
    }
    
    func applyConfiguration(_ config: NaverMapConfiguration) {
        guard let mapView else { return }
        
        mapView.mapType = config.mapType.nmfMapType
        mapView.minZoomLevel = config.minZoom
        mapView.maxZoomLevel = config.maxZoom
        
        // 제스처
        mapView.isScrollGestureEnabled = config.scrollGestureEnabled
        mapView.isZoomGestureEnabled = config.zoomGestureEnabled
        mapView.isTiltGestureEnabled = config.tiltGestureEnabled
        mapView.isRotateGestureEnabled = config.rotateGestureEnabled
        
        // 야간 모드
        mapView.isNightModeEnabled = config.nightMode
    }
    
    func moveCamera(to position: CLLocationCoordinate2D, zoom: Double? = nil, animated: Bool = true) {
        guard let mapView else { return }
        
        let targetZoom = zoom ?? mapView.cameraPosition.zoom
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: position.latitude, lng: position.longitude),
            zoom: targetZoom
        )
        let update = NMFCameraUpdate(position: cameraPosition)
        if animated {
            update.animation = .easeIn
            update.animationDuration = 0.5
        }
        mapView.moveCamera(update)
    }
    
    func cleanup() {
        markers.values.forEach { $0.mapView = nil }
        markers.removeAll()
        circleOverlays.values.forEach { $0.mapView = nil }
        circleOverlays.removeAll()
        pathOverlay?.mapView = nil
        pathOverlay = nil
        arrowPathOverlay?.mapView = nil
        arrowPathOverlay = nil
        
        clusterer?.mapView = nil
        clusterer = nil
        
        mapView?.removeCameraDelegate(delegate: self)
        mapView?.touchDelegate = nil
        mapView = nil
    }
}

extension NaverMapCoordinator: NMFMapViewCameraDelegate {
    public func mapView(_: NMFMapView, cameraWillChangeByReason _: Int, animated _: Bool) {}
    public func mapView(_: NMFMapView, cameraIsChangingByReason _: Int) {}
    
    @MainActor
    public func mapViewCameraIdle(_ mapView: NMFMapView) {
        lastCameraPosition = mapView.cameraPosition
        
        Task { @MainActor in
            parent.cameraPosition = mapView.cameraPosition
            parent.onCameraChange?(mapView.cameraPosition)
        }
    }
}

extension NaverMapCoordinator: NMFMapViewTouchDelegate {
    public func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
        let coordinate = CLLocationCoordinate2D(latitude: latlng.lat, longitude: latlng.lng)
        parent.onMapTap?(coordinate)
    }
}
