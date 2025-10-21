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
    // TODO: 임시로 클러스터 모드 제거
    @Published var clusteringEnabled = false
    
    @Published var positionMode: NMFMyPositionMode = .normal
    
    @Published var currentCase: Case?
    @Published var caseLocations: [CaseLocation] = []
    
    // 위치별 체류 정보
    @Published var locationStays: [LocationStay] = []
    
    // 검색 결과 바텀시트 관련
    @Published var selectedSearchResult: LocalSearchResult?
    @Published var showSearchResultSheet = false
    
    private var modelContext: ModelContext?
    // TODO: protocol 리팩토링 예정
    private let locationService = LocationService()
    
    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }
    
    // ✅ 수정된 메서드
    func loadLocations(for selectedCase: Case) {
        guard let modelContext else {
            print("❌ ModelContext not set")
            return
        }
          
        currentCase = selectedCase
          
        // ✅ Case의 locations 관계를 직접 사용
        let fetchedLocations = selectedCase.locations
            .filter { $0.latitude != nil && $0.longitude != nil }
            .sorted { $0.receivedAt > $1.receivedAt }
          
        print("✅ Loaded \(fetchedLocations.count) locations for case: \(selectedCase.name)")
          
        caseLocations = fetchedLocations
          
        // 지도 마커 데이터
        locations = fetchedLocations.compactMap { location in
            guard let lat = location.latitude,
                  let lng = location.longitude
            else {
                return nil
            }
              
            return NaverMapLocationData(
                id: location.id,
                coordinate: CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lng
                ),
                timestamp: location.receivedAt,
                address: location.address ?? "위치",
                additionalInfo: [:]
            )
        }
          
        // 체류 정보 생성
        locationStays = LocationStay.groupByConsecutiveLocation(from: fetchedLocations)
        print("✅ 생성된 체류 정보: \(locationStays.count)개")
          
        moveCameraToLatestMarker()
    }
    
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
    
    // mvp 용
    func loadAllLocations() {
        var allLocations: [NaverMapLocationData] = []
        
        // 1. 실제 데이터 로드
        if let modelContext {
            let descriptor = FetchDescriptor<CaseLocation>(
                predicate: #Predicate { location in
                    location.latitude != nil &&
                        location.longitude != nil
                },
                sortBy: [SortDescriptor(\.receivedAt, order: .reverse)]
            )
            
            do {
                let caseLocations = try modelContext.fetch(descriptor)
                print("Loaded \(caseLocations.count) real locations")
                
                let realLocations = caseLocations.compactMap { location -> NaverMapLocationData? in
                    guard let lat = location.latitude,
                          let lng = location.longitude
                    else {
                        return nil
                    }
                    
                    return NaverMapLocationData(
                        id: location.id,
                        coordinate: CLLocationCoordinate2D(
                            latitude: lat,
                            longitude: lng
                        ),
                        timestamp: location.receivedAt,
                        address: location.address ?? "위치",
                        additionalInfo: [:]
                    )
                }
                
                allLocations.append(contentsOf: realLocations)
            } catch {
                print("Failed to fetch real locations: \(error)")
            }
        }
        
        // 2. Mock 데이터 로드
        let mockLocations = MockLocationLoader.loadFromJSON()
        let mockNaverLocations = mockLocations.map { mock in
            NaverMapLocationData(
                id: UUID(),
                coordinate: mock.coordinate,
                timestamp: mock.timestamp,
                address: mock.location,
                additionalInfo: [:]
            )
        }
        
        allLocations.append(contentsOf: mockNaverLocations)
        
        // 3. 시간순 정렬 (최신순)
        locations = allLocations.sorted { $0.timestamp > $1.timestamp }
        
        moveCameraToLatestMarker()
        print("Loaded total \(locations.count) locations (real: \(allLocations.count - mockNaverLocations.count), mock: \(mockNaverLocations.count))")
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
        
        // 실시간 업데이트
        
        if let currentCase {
            loadLocations(for: currentCase)
        }
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
    
    // ✅ 새로 추가: 외부에서 locations 업데이트
    func updateLocations(with caseLocations: [CaseLocation]) {
        self.caseLocations = caseLocations
           
        // 지도 마커 데이터
        locations = caseLocations.compactMap { location in
            guard let lat = location.latitude,
                  let lng = location.longitude
            else {
                return nil
            }
               
            return NaverMapLocationData(
                id: location.id,
                coordinate: CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lng
                ),
                timestamp: location.receivedAt,
                address: location.address ?? "위치",
                additionalInfo: [:]
            )
        }
           
        // 체류 정보 생성
        locationStays = LocationStay.groupByConsecutiveLocation(from: caseLocations)
           
        print("✅ Updated locations:")
        print("   - Map markers: \(locations.count)")
        print("   - Location stays: \(locationStays.count)")
           
        // 카메라 이동 (새 데이터가 있을 때만)
        if !locations.isEmpty {
            moveCameraToLatestMarker()
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
