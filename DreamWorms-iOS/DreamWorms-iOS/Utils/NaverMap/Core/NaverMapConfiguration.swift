//
//  NaverMapConfiguration.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import CoreLocation
import Foundation
import NMapsMap

public struct NaverMapConfiguration: Sendable {
    // 카메라
    public var initialPosition: CLLocationCoordinate2D
    public var initialZoom: Double
    public var minZoom: Double
    public var maxZoom: Double
    
    // 지도 타입 및 UI
    public var mapType: NaverMapType
    public var showLocationButton: Bool
    public var showCompass: Bool
    public var showZoomControls: Bool
    
    // 제스처
    public var scrollGestureEnabled: Bool
    public var zoomGestureEnabled: Bool
    public var tiltGestureEnabled: Bool
    public var rotateGestureEnabled: Bool
    
    // 스타일
    public var nightMode: Bool
    public var buildingHeight: Double
    
    // 클러스터링
    public var clusteringEnabled: Bool
    
    public enum NaverMapType: String, CaseIterable, Sendable {
        case normal, satellite, hybrid, terrain
        
        public var nmfMapType: NMFMapType {
            switch self {
            case .normal: .basic
            case .satellite: .satellite
            case .hybrid: .hybrid
            case .terrain: .terrain
            }
        }
    }
    
    public init(
        // TODO: 위치 데이터가 하나도 없고, 위치 권한도 불러오지 못한다면 어떤 좌표로 가져올 건지 정할 것
        // 지금은 포항시로 해두었음.
        initialPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 36.0190, longitude: 129.3435),
        initialZoom: Double = 13.0,
        minZoom: Double = 5.0,
        maxZoom: Double = 18.0,
        mapType: NaverMapType = .normal,
        showLocationButton: Bool = true,
        showZoomControls: Bool = false,
        showCompass: Bool = true,
        scrollGestureEnabled: Bool = true,
        zoomGestureEnabled: Bool = true,
        tiltGestureEnabled: Bool = false,
        rotateGestureEnabled: Bool = true,
        nightMode: Bool = false,
        buildingHeight: Double = 1.0,
        clusteringEnabled: Bool = false // 기본값 false
    ) {
        self.initialPosition = initialPosition
        self.initialZoom = initialZoom
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.mapType = mapType
        self.showLocationButton = showLocationButton
        self.showZoomControls = showZoomControls
        self.showCompass = showCompass
        self.scrollGestureEnabled = scrollGestureEnabled
        self.zoomGestureEnabled = zoomGestureEnabled
        self.tiltGestureEnabled = tiltGestureEnabled
        self.rotateGestureEnabled = rotateGestureEnabled
        self.nightMode = nightMode
        self.buildingHeight = buildingHeight
        self.clusteringEnabled = clusteringEnabled
    }
    
    // TODO: 지도 커스텀시 사용 현재는 디폴트
    public static var defaultConfig: Self { Self() }
}
