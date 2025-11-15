//
//  LocationOverviewFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 11/9/25.
//

import SwiftUI

struct LocationOverviewFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    init(repository: LocationRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        /// 현재 선택된 케이스 ID
        var caseID: UUID?

        /// Dashboard 에서 탭한 기준 기지국 주소 (타이틀 & 필터 기준)
        var baseAddress: String = ""

        /// 기준 중심 좌표 (기지국 위치)
        var centerCoordinate: MapCoordinate?

        /// 현재 선택된 카테고리
        var selection: Category = .all

        /// 기준 반경 내 모든 핀 (필터 전)
        var allLocations: [Location] = []

        /// 현재 selection 에 따른 필터링 결과
        var filteredLocations: [Location] = []

        /// 카테고리별 개수 (배지용)
        var counts: [Category: Int] = [:]
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear(caseID: UUID, baseAddress: String, initialCoordinate: MapCoordinate)
        case selectionChanged(Category)
        case setLocations([Location])
        case refreshFilterAndCounts
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .onAppear(caseID, baseAddress, initialCoordinate):
            state.caseID = caseID
            state.baseAddress = baseAddress
            state.centerCoordinate = initialCoordinate
            
            return .task { [repository] in
                do {
                    let allTypes = await Category.all.types
                    let locations = try await repository.fetchNoCellLocations(
                        caseId: caseID,
                        locationType: allTypes
                    )
                    return .setLocations(locations)
                } catch {
                    return .setLocations([])
                }
            }
            
        case let .setLocations(locations):
            state.allLocations = locations
            return .send(.refreshFilterAndCounts)
            
        case let .selectionChanged(category):
            state.selection = category
            return .send(.refreshFilterAndCounts)
            
        case .refreshFilterAndCounts:
            applyFilterAndCounts(into: &state)
            return .none
        }
    }
}

// MARK: - Private Extensions

private extension LocationOverviewFeature {
    /// 현재 center / selection / allLocations 를 기준으로
    /// - 500m 반경 내 Location 필터링
    /// - 카테고리별 카운트 계산
    /// - filteredLocations 업데이트
    func applyFilterAndCounts(into state: inout State) {
        // 중심 좌표가 없으면 초기화 후 종료
        guard let center = state.centerCoordinate else {
            state.filteredLocations = []
            state.counts = [:]
            return
        }
        
        // 1. 중복 주소 통합
        let unique = uniqueLocations(state.allLocations)
        
        // 2. LocationType == 2 (기지국) 제거
        let noBaseStation = removeBaseStations(unique)
        
        // 3. 중심 좌표 기준 반경 내 Location만 추리기
        let inRange = noBaseStation.filter { loc in
            isWithinRadius(center: center, location: loc)
        }
        
        // 4. 카테고리별 카운트 계산 (헤더용) — inRange 기준
        var counts: [Category: Int] = [:]
        for category in Category.allCases {
            let types = category.types
            counts[category] = inRange.filter { loc in
                types.contains(Int(loc.locationType))
            }.count
        }
        state.counts = counts
        
        // 5. 현재 선택된 카테고리에 맞춰 리스트 필터링
        let selectedTypes = state.selection.types
        state.filteredLocations = inRange.filter { loc in
            selectedTypes.contains(Int(loc.locationType))
        }
    }
        
    /// 주소 기준으로 중복 Location을 하나로 통합합니다.
    /// 같은 주소가 여러 번 등장할 경우, 가장 마지막에 등장한 Location이 사용됩니다.
    func uniqueLocations(_ locations: [Location]) -> [Location] {
        var dict: [String: Location] = [:]
        for loc in locations {
            dict[loc.address, default: loc] = loc
        }
        return Array(dict.values)
    }
    
    /// LocationType == 2(기지국)인 Location을 필터링하여 제거합니다.
    func removeBaseStations(_ locations: [Location]) -> [Location] {
        locations.filter { $0.locationType != 2 }
    }
        
    /// 중심 좌표에서 주어진 Location까지의 거리가 radius(m) 이하인지 확인합니다.
    func isWithinRadius(
        center: MapCoordinate,
        location: Location,
        radius: Double = 500
    ) -> Bool {
        let lat1 = center.latitude * .pi / 180
        let lon1 = center.longitude * .pi / 180
        let lat2 = location.pointLatitude * .pi / 180
        let lon2 = location.pointLongitude * .pi / 180
        
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        
        // Haversine formula
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let earthRadius: Double = 6_371_000 // m
        let distance = earthRadius * c
        
        return distance <= radius
    }
}
