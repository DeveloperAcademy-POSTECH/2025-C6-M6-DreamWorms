//
//  TrackingFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct TrackingFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    private let cctvService: CCTVAPIService
    
    init(
        repository: LocationRepositoryProtocol,
        cctvService: CCTVAPIService
    ) {
        self.repository = repository
        self.cctvService = cctvService
    }
    
    // MARK: - State
    
    struct State: DWState {
        var caseId: UUID?
        var locations: [Location] = []
        var isLoading: Bool = false
        var cctvMarkers: [CCTVMarker] = []
        var isCCTVLoading: Bool = false
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear(UUID)
        case locationsLoaded([Location])
        case requestCCTV([Location])
        case cctvResponse(Result<[CCTVMarker], VWorldError>)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .onAppear(caseId):
            state.caseId = caseId
            state.isLoading = true
            
            return .task { [repository] in
                do {
                    let locations = try await repository.fetchLocations(caseId: caseId)
                    return .locationsLoaded(locations)
                } catch {
                    return .locationsLoaded([])
                }
            }
            
        case let .locationsLoaded(locations):
            state.locations = locations.deduplicatedByCoordinate()
            state.isLoading = false
            return .none
        
        case let .requestCCTV(locations):
            guard locations.count >= 3 else {
                state.cctvMarkers = []
                return .none
            }
            
            state.isCCTVLoading = true
            let polygonCoordinates = makeClosedPolygonCoordinates(from: locations)
            let dto = VWorldPolygonRequestDTO(
                coordinates: polygonCoordinates,
                size: 1000,
                page: 1
            )
            
            return .task { [cctvService] in
                do {
                    let response = try await cctvService.fetchCCTVByPolygon(dto)
                    
                    let markers: [CCTVMarker] = response.features.compactMap { feature in
                        guard feature.geometry.coordinates.count >= 2 else { return nil }
                        let lon = feature.geometry.coordinates[0]
                        let lat = feature.geometry.coordinates[1]
                        
                        return CCTVMarker(
                            id: feature.id,
                            name: feature.properties.cctvname,
                            location: feature.properties.locate,
                            latitude: lat,
                            longitude: lon
                        )
                    }
                    
                    return .cctvResponse(.success(markers))
                } catch let error as VWorldError {
                    return .cctvResponse(.failure(error))
                } catch {
                    return .cctvResponse(.failure(.unknown(error)))
                }
            }
            
        case let .cctvResponse(result):
            state.isCCTVLoading = false
            
            switch result {
            case let .success(markers):
                state.cctvMarkers = markers
            case let .failure(_):
                state.cctvMarkers = []
            }
            
            return .none
        }
    }
}

private extension TrackingFeature {
    /// Location 배열로부터 VWorld POLYGON용 좌표 배열을 만듭니다.
    /// - Note: VWorld는 `POLYGON((x1 y1, x2 y2, ..., x1 y1))` 형태로 **닫힌 폴리곤**을 요구하므로 첫 번째 좌표를 마지막에 한 번 더 추가합니다.
    func makeClosedPolygonCoordinates(from locations: [Location]) -> [MapCoordinate] {
        var coords: [MapCoordinate] = locations.map {
            MapCoordinate(
                latitude: $0.pointLatitude,
                longitude: $0.pointLongitude
            )
        }
        if let first = coords.first { coords.append(first) }
        
        return coords
    }
}

private extension Array<Location> {
    /// pointLatitude + pointLongitude 기준 중복 제거 (Dictionary 사용 안함)
    /// 동일 좌표가 여러 개 있는 경우 가장 최신 receivedAt Location만 남김
    func deduplicatedByCoordinate() -> [Location] {
        var result: [Location] = []
        
        for loc in self {
            // 좌표가 없는 경우 스킵
            guard loc.pointLatitude != 0, loc.pointLongitude != 0 else { continue }
            
            if let existingIndex = result.firstIndex(where: {
                $0.pointLatitude == loc.pointLatitude &&
                    $0.pointLongitude == loc.pointLongitude
            }) {
                // 이미 같은 좌표가 있을 때 → 더 최신 것으로 교체
                let existing = result[existingIndex]
                
                let existingDate = existing.receivedAt ?? .distantPast
                let newDate = loc.receivedAt ?? .distantPast
                
                if newDate > existingDate {
                    result[existingIndex] = loc
                }
            } else {
                // 최초 발견된 좌표 → 추가
                result.append(loc)
            }
        }
        
        return result
    }
}
