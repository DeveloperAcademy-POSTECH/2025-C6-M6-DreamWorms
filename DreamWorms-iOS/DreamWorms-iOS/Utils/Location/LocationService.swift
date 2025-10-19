//
//  LocationService.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/19/25.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isUpdatingLocation = false
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var timeoutTask: Task<Void, Never>?
    private var isRequestingLocation = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestAuthorization() {
        guard authorizationStatus == .notDetermined else {
            print("Authorization already determined: \(authorizationStatus.description)")
            return
        }
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways
        else {
            print("Location authorization not granted")
            return
        }
        
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
        print("Started updating location")
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false
        print("Stopped updating location")
    }
    
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        // 이미 요청 중이면 대기
        if isRequestingLocation {
            print("Location request already in progress, waiting...")
            // 기존 요청이 완료될 때까지 대기
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1초 대기
            
            // 현재 위치가 있으면 반환
            if let currentLocation {
                return currentLocation
            }
            
            throw LocationError.locationUnavailable
        }
        
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways
        else {
            throw LocationError.authorizationDenied
        }
        
        // 이전 요청 정리
        cleanupPreviousRequest()
        
        isRequestingLocation = true
        
        defer {
            isRequestingLocation = false
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            
            timeoutTask = Task {
                try? await Task.sleep(nanoseconds: 10_000_000_000) // 10초
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    if let pendingContinuation = self.locationContinuation {
                        pendingContinuation.resume(throwing: LocationError.timeout)
                        self.locationContinuation = nil
                        self.isRequestingLocation = false
                        print("Location request timeout")
                    }
                }
            }
            
            print("Requesting single location update...")
            locationManager.requestLocation()
        }
    }
    
    private func cleanupPreviousRequest() {
        timeoutTask?.cancel()
        timeoutTask = nil
        
        if let continuation = locationContinuation {
            continuation.resume(throwing: LocationError.requestCancelled)
            locationContinuation = nil
        }
    }
    
    // 현재 위치를 즉시 가져오는 대체 메서드
    func getCurrentLocationImmediately() async throws -> CLLocationCoordinate2D {
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways
        else {
            throw LocationError.authorizationDenied
        }
        
        // 이미 저장된 현재 위치가 있으면 바로 반환
        if let currentLocation {
            print("Returning cached location")
            return currentLocation
        }
        
        // 위치 업데이트 시작
        startUpdatingLocation()
        
        // 최대 3초 동안 위치 업데이트 대기
        for _ in 0 ..< 30 {
            if let location = currentLocation {
                stopUpdatingLocation()
                return location
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1초
        }
        
        stopUpdatingLocation()
        throw LocationError.locationUnavailable
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            print("Location authorization status: \(status.description)")
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // 권한 획득 시 자동으로 위치 업데이트 시작하지 않음
                print("Location authorization granted")
            case .denied, .restricted:
                print("Location access denied or restricted")
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        
        Task { @MainActor in
            currentLocation = coordinate
            print("Location updated: \(coordinate.latitude), \(coordinate.longitude)")
            
            if let continuation = locationContinuation {
                timeoutTask?.cancel()
                timeoutTask = nil
                continuation.resume(returning: coordinate)
                locationContinuation = nil
                isRequestingLocation = false
            }
        }
    }
    
    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        let errorDescription = error.localizedDescription
        
        Task { @MainActor in
            print("Location error: \(errorDescription)")
            
            // kCLErrorLocationUnknown 에러는 무시 (일시적인 에러)
            if (error as NSError).code == 0 {
                print("Temporary location error, will retry...")
                return
            }
            
            if let continuation = locationContinuation {
                timeoutTask?.cancel()
                timeoutTask = nil
                continuation.resume(throwing: error)
                locationContinuation = nil
                isRequestingLocation = false
            }
        }
    }
}

enum LocationError: LocalizedError {
    case authorizationDenied
    case locationUnavailable
    case timeout
    case requestCancelled
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            "위치 권한이 거부되었습니다"
        case .locationUnavailable:
            "현재 위치를 가져올 수 없습니다"
        case .timeout:
            "위치 요청 시간이 초과되었습니다"
        case .requestCancelled:
            "이전 위치 요청이 취소되었습니다"
        }
    }
}

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown"
        }
    }
}
