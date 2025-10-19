//
//  MapViewModel.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/19/25.
//

import Combine
import CoreLocation
import NMapsMap
import SwiftData
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
    @Published var cameraPosition: NMFCameraPosition?
    @Published var locations: [NaverMapLocationData] = []
    @Published var displayMode: NaverMapDisplayMode = .uniqueLocations
    @Published var overlayOptions = NaverMapOverlayOptions()
    @Published var clusteringEnabled = true
    
    @Published var positionMode: NMFMyPositionMode = .normal
    
    // 검색 결과 바텀시트 관련
    @Published var selectedSearchResult: LocalSearchResult?
    @Published var showSearchResultSheet = false
    
    private var modelContext: ModelContext?
    // TODO: protocol 리팩토링 예정
    private let locationService = LocationService()
    
    func setModelContext(_ context: ModelContext) {
        modelContext = context
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
        displayMode = displayMode == .frequency ? .uniqueLocations : .frequency
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
                locationService.authorizationStatus == .authorizedAlways
            else {
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
    
    init() {
        // 검색 결과 선택 시 지도 이동 + 바텀시트 표시 알림 받기
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowSearchResult"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let result = notification.object as? LocalSearchResult {
                // 1. 바텀시트 표시
                self?.selectedSearchResult = result
                self?.showSearchResultSheet = true
                
                // 2. 지도 이동
                self?.cameraPosition = NMFCameraPosition(
                    NMGLatLng(lat: result.coordinate.latitude, lng: result.coordinate.longitude),
                    zoom: 16.0
                )
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
