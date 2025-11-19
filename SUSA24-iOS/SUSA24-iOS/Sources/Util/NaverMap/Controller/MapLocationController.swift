//
//  MapLocationController.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/25/25.
//

import CoreLocation
import Foundation
import NMapsMap

/// 사용자 위치 관리 및 초기 위치 설정을 담당하는 컨트롤러
@MainActor
final class MapLocationController: NSObject, CLLocationManagerDelegate {
    // MARK: - Properties
    
    /// 위치 관리자
    private let locationManager = CLLocationManager()
    
    /// 네이버 지도 뷰 인스턴스에 대한 약한 참조 (Coordinator의 mapView와 동일한 인스턴스)
    /// - Note: `updateUIView`에서 Coordinator의 mapView와 동일한 인스턴스를 할당합니다.
    weak var mapView: NMFMapView?
    
    /// 마지막으로 알려진 위치
    private var lastKnownLocation: CLLocationCoordinate2D?
    
    /// 초기 위치로 한 번만 카메라를 이동했는지 여부
    private var hasCenteredOnUserOnce = false
    
    /// 위치 업데이트 콜백
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    
    /// 초기 위치 설정 콜백
    var onInitialLocation: ((MapCoordinate) -> Void)?
    
    /// 현위치 포커싱 콜백 (성공/실패)
    var onFocusMyLocation: ((Bool) -> Void)?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = MapConstants.locationAccuracy
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Location Management
    
    /// 위치 업데이트를 시작합니다.
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /// 위치 업데이트를 중지합니다.
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 현재 위치로 카메라를 포커싱합니다.
    /// - Parameter moveCamera: 카메라 이동 콜백
    /// - Returns: 위치 정보를 성공적으로 가져왔는지 여부
    func focusOnCurrentLocation(moveCamera: ((MapCoordinate) -> Void)?) -> Bool {
        guard let mapView else { return false }
        mapView.positionMode = .normal
        let overlay = mapView.locationOverlay
        guard overlay.hidden == false else { return false }
        
        let currentLocation = overlay.location
        let coordinate = MapCoordinate(latitude: currentLocation.lat, longitude: currentLocation.lng)
        
        moveCamera?(coordinate)
        return true
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// 위치 권한 상태가 변경될 때 호출되는 메서드입니다.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    /// 새로운 위치 정보가 들어올 때마다 호출되는 메서드입니다.
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        lastKnownLocation = coordinate
        
        // 지도 오버레이 업데이트
        if let mapView {
            let overlay = mapView.locationOverlay
            overlay.location = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            overlay.hidden = false
        }
        
        // 위치 업데이트 콜백 호출
        onLocationUpdate?(coordinate)
        
        // 초기 위치 설정 (한 번만)
        if !hasCenteredOnUserOnce {
            hasCenteredOnUserOnce = true
            let target = MapCoordinate(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            onInitialLocation?(target)
        }
    }
}
