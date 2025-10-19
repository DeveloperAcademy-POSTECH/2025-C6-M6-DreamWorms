//
//  MapViewModel.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/19/25.
//

import SwiftUI
import SwiftData
import NMapsMap
import Combine
import CoreLocation

@MainActor
final class MapViewModel: ObservableObject {
    @Published var cameraPosition: NMFCameraPosition?
    @Published var locations: [NaverMapLocationData] = []
    @Published var displayMode: NaverMapDisplayMode = .uniqueLocations
    @Published var overlayOptions = NaverMapOverlayOptions()
    @Published var clusteringEnabled = true
    
    @Published var positionMode: NMFMyPositionMode = .normal
    
    private var modelContext: ModelContext?
    private let locationService = LocationService()
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // TODO: 실 데이터 연동
    //    func loadLocations() {
    //        guard let modelContext = modelContext else {
    //            print("ModelContext not set")
    //            return
    //        }
    //
    //        let descriptor = FetchDescriptor<CaseLocation>(
    //            predicate: #Predicate { location in
    //                location.pinType == .telecom &&
    //                location.latitude != nil &&
    //                location.longitude != nil
    //            },
    //            sortBy: [SortDescriptor(\.receivedAt, order: .reverse)]
    //        )
    //
    //        do {
    //            let caseLocations = try modelContext.fetch(descriptor)
    //            print("Loaded \(caseLocations.count) telecom locations")
    //
    //            locations = caseLocations.compactMap { location in
    //                guard let lat = location.latitude,
    //                      let lng = location.longitude else {
    //                    return nil
    //                }
    //
    //                return NaverMapLocationData(
    //                    id: location.id,
    //                    coordinate: CLLocationCoordinate2D(
    //                        latitude: lat,
    //                        longitude: lng
    //                    ),
    //                    timestamp: location.receivedAt,
    //                    address: location.address ?? "위치",
    //                    additionalInfo: [:]
    //                )
    //            }
    //
    //            moveCameraToLatestMarker()
    //
    //        } catch {
    //            print("Failed to fetch locations: \(error)")
    //        }
    //    }
    
    // Mock json 파일 데이터
    func loadMockLocations() {
        let mockLocations = MockLocationLoader.loadFromJSON()
        
        locations = mockLocations.map { mock in
            NaverMapLocationData(
                id: UUID(),
                coordinate: mock.coordinate,
                timestamp: mock.timestamp,
                address: mock.location,
                additionalInfo: [:]
            )
        }
        
        moveCameraToLatestMarker()
        print("Loaded \(locations.count) mock locations")
    }
    
    func toggleFrequencyMode() {
        displayMode = displayMode == .countFrequency ? .uniqueLocations : .countFrequency
        print("Display mode: \(displayMode.rawValue)")
    }
    
    func toggleCircleOverlay() {
        overlayOptions.showCircleOverlay.toggle()
        print("Circle overlay: \(overlayOptions.showCircleOverlay)")
    }
    
    func refreshData() {
        //        loadLocations()
        moveCameraToLatestMarker()
        print("Data refreshed")
    }
    
    func moveToMyLocation() {
        Task {
            if locationService.authorizationStatus == .notDetermined {
                locationService.requestAuthorization()
                print("권한 요청 필요")
                return
            }
            
            guard locationService.authorizationStatus == .authorizedWhenInUse ||
                    locationService.authorizationStatus == .authorizedAlways else {
                print("위치 권한이 없습니다")
                return
            }
            
            do {
                let coordinate = try await locationService.requestCurrentLocation()
                
                cameraPosition = NMFCameraPosition(
                    NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
                    zoom: 16.0
                )
            } catch {
                // TODO: 에러처리 필요
                print("위치 가져오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func moveCameraToLatestMarker() {
        guard let latest = locations.first else {
            print("No locations to move camera")
            return
        }
        
        cameraPosition = NMFCameraPosition(
            NMGLatLng(
                lat: latest.coordinate.latitude,
                lng: latest.coordinate.longitude
            ),
            zoom: 15.0
        )
    }
}
