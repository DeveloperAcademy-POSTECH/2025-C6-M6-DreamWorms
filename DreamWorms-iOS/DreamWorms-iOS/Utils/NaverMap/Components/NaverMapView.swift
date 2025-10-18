//
//  NaverMapView.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import SwiftUI
import NMapsMap
import CoreLocation

public struct NaverMapView: UIViewRepresentable {
    
    // 실시간성
    @Binding var cameraPosition: NMFCameraPosition?
    @Binding var positionMode: NMFMyPositionMode
    
    let configuration: NaverMapConfiguration
    let markers: [NaverMapMarkerData]
    let displayMode: NaverMapDisplayMode
    let overlayOptions: NaverMapOverlayOptions
    let locations: [NaverMapLocationData]
    
    let onMarkerTap: ((NaverMapMarkerData) -> Void)?
    let onMapTap: ((CLLocationCoordinate2D) -> Void)?
    let onCameraChange: ((NMFCameraPosition) -> Void)?
    
    public init(
        cameraPosition: Binding<NMFCameraPosition?> = .constant(nil),
        positionMode: Binding<NMFMyPositionMode> = .constant(.disabled),
        configuration: NaverMapConfiguration = .defaultConfig,
        markers: [NaverMapMarkerData] = [],
        displayMode: NaverMapDisplayMode = .uniqueLocations,
        overlayOptions: NaverMapOverlayOptions = NaverMapOverlayOptions(),
        locations: [NaverMapLocationData] = [],
        onMarkerTap: ((NaverMapMarkerData) -> Void)? = nil,
        onMapTap: ((CLLocationCoordinate2D) -> Void)? = nil,
        onCameraChange: ((NMFCameraPosition) -> Void)? = nil
    ) {
        self._cameraPosition = cameraPosition
        self._positionMode = positionMode
        self.configuration = configuration
        self.markers = markers
        self.displayMode = displayMode
        self.overlayOptions = overlayOptions
        self.locations = locations
        self.onMarkerTap = onMarkerTap
        self.onMapTap = onMapTap
        self.onCameraChange = onCameraChange
    }
    
    public func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView(frame: .zero)
        context.coordinator.setupMapView(mapView.mapView)
        updateMapContent(mapView.mapView, coordinator: context.coordinator)
        return mapView
    }
    
    public func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let mapView = uiView.mapView
        let coordinator = context.coordinator
        
        coordinator.applyConfiguration(configuration)
        
        // 줌 레벨에 따른 자동 클러스터링
        let currentZoom = mapView.zoomLevel
        let shouldCluster = currentZoom < 14.0
        coordinator.autoClusteringEnabled = shouldCluster
        
        updateMapContent(mapView, coordinator: coordinator)
        
        if let position = cameraPosition,
           position != coordinator.lastCameraPosition {
            let update = NMFCameraUpdate(position: position)
            update.animation = .easeIn
            update.animationDuration = 0.3
            mapView.moveCamera(update)
            coordinator.lastCameraPosition = position
        }
    }
    
    public func makeCoordinator() -> NaverMapCoordinator {
        NaverMapCoordinator(self)
    }
    
    public static func dismantleUIView(_ uiView: NMFNaverMapView, coordinator: NaverMapCoordinator) {
        coordinator.cleanup()
    }
    
    private func updateMapContent(_ mapView: NMFMapView, coordinator: NaverMapCoordinator) {
        let processedMarkers = processMarkers()
        
        // 자동 클러스터링 여부 확인
        let isClusteringActive = configuration.clusteringEnabled && coordinator.autoClusteringEnabled
        
        NaverMapMarkerManager.updateMarkers(
            coordinator: coordinator,
            markers: processedMarkers
        ) { markerData in
            onMarkerTap?(markerData)
        }
        
        // 클러스터링이 활성화되면 Circle Overlay 비활성화
        let shouldShowCircle = overlayOptions.showCircleOverlay && !isClusteringActive
        
        NaverMapOverlayManager.updateCircleOverlays(
            coordinator: coordinator,
            markers: processedMarkers,
            radius: overlayOptions.circleRadius,
            show: shouldShowCircle
        )
        
        if overlayOptions.showFlowPath && displayMode == .flow {
            NaverMapOverlayManager.updateFlowPath(
                coordinator: coordinator,
                locations: locations,
                showArrows: true
            )
        } else {
            coordinator.pathOverlay?.mapView = nil
            coordinator.arrowPathOverlay?.mapView = nil
        }
    }
    
    private func processMarkers() -> [NaverMapMarkerData] {
        switch displayMode {
        case .uniqueLocations:
            return processUniqueLocations()
        case .frequency:
            return processFrequencyMarkers()
        case .timeSequence:
            return processTimeSequenceMarkers()
        case .flow:
            return processFlowMarkers()
        }
    }
    
    private func processUniqueLocations() -> [NaverMapMarkerData] {
        var uniqueMap: [String: NaverMapLocationData] = [:]
        
        for location in locations {
            let key = location.coordinateKey
            if uniqueMap[key] == nil {
                uniqueMap[key] = location
            }
        }
        
        return uniqueMap.values.map { location in
            NaverMapMarkerData(
                coordinate: location.coordinate,
                title: location.address.isEmpty ? "위치" : location.address,
                subtitle: location.formattedTimestamp,
                markerType: .uniqueLocations
            )
        }
    }
    
    private func processFrequencyMarkers() -> [NaverMapMarkerData] {
        var frequencyMap: [String: (location: NaverMapLocationData, count: Int)] = [:]
        
        for location in locations {
            let key = location.coordinateKey
            if let existing = frequencyMap[key] {
                frequencyMap[key] = (location, existing.count + 1)
            } else {
                frequencyMap[key] = (location, 1)
            }
        }
        
        return frequencyMap.values.map { item in
            NaverMapMarkerData(
                coordinate: item.location.coordinate,
                title: item.location.address.isEmpty ? "위치" : item.location.address,
                frequency: item.count,
                markerType: .frequency
            )
        }
    }
    
    private func processTimeSequenceMarkers() -> [NaverMapMarkerData] {
        let sorted = locations.sorted { $0.timestamp < $1.timestamp }
        var groups: [[NaverMapLocationData]] = []
        var currentGroup: [NaverMapLocationData] = []
        
        for location in sorted {
            if let last = currentGroup.last {
                if last.coordinateKey == location.coordinateKey {
                    currentGroup.append(location)
                } else {
                    if !currentGroup.isEmpty {
                        groups.append(currentGroup)
                    }
                    currentGroup = [location]
                }
            } else {
                currentGroup = [location]
            }
        }
        
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        var markers: [NaverMapMarkerData] = []
        for (index, group) in groups.enumerated() {
            if let first = group.first {
                markers.append(
                    NaverMapMarkerData(
                        coordinate: first.coordinate,
                        title: first.address.isEmpty ? "위치 \(index + 1)" : first.address,
                        frequency: group.count,
                        groupIndex: index,
                        markerType: .timeSequence
                    )
                )
            }
        }
        
        return markers
    }
    
    private func processFlowMarkers() -> [NaverMapMarkerData] {
        let sorted = locations.sorted { $0.timestamp < $1.timestamp }
        var markers: [NaverMapMarkerData] = []
        
        if let first = sorted.first {
            markers.append(
                NaverMapMarkerData(
                    coordinate: first.coordinate,
                    title: "시작",
                    subtitle: first.formattedTimestamp,
                    markerType: .timeSequence
                )
            )
        }
        
        if sorted.count > 1, let last = sorted.last {
            markers.append(
                NaverMapMarkerData(
                    coordinate: last.coordinate,
                    title: "종료",
                    subtitle: last.formattedTimestamp,
                    markerType: .timeSequence
                )
            )
        }
        
        return markers
    }
}
