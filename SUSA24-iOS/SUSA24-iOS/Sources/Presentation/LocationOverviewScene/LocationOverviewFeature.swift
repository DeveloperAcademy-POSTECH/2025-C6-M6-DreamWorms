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
            // 중심 좌표가 없으면 초기화 후 종료
            guard let center = state.centerCoordinate else {
                state.filteredLocations = []
                state.counts = [:]
                return .none
            }

            // 1. 중복 주소 통합
            let unique = uniqueLocations(state.allLocations)

            // 2. LocationType == 2 (기지국) 제거
            let noBaseStation = removeBaseStations(unique)

            // 3. 중심 좌표 기준 bounding box 계산 (500m)
            let bbox = boundingBoxFor(
                coordinate: center,
                radius: 500
            )

            // 4. bounding box 안에 포함된 Location만 추리기
            let inRange = noBaseStation.filter { loc in
                isInsideBoundingBox(loc: loc, bbox: bbox)
            }

            // 5. 카테고리별 카운트 계산 (헤더용) — inRange 기준
            var counts: [Category: Int] = [:]
            for category in Category.allCases {
                let types = category.types
                counts[category] = inRange.filter { loc in
                    types.contains(Int(loc.locationType))
                }.count
            }
            state.counts = counts

            // 6. 현재 선택된 카테고리에 맞춰 리스트 필터링
            let selectedTypes = state.selection.types
            state.filteredLocations = inRange.filter { loc in
                selectedTypes.contains(Int(loc.locationType))
            }

            return .none
        }
    }
}

private extension LocationOverviewFeature {
    /// Bounding Box를 표현하기 위한 타입 별칭입니다.
    /// - minLat / maxLat: 남-북 방향 경계
    /// - minLon / maxLon: 서-동 방향 경계
    typealias BoundingBox = (minLat: Double, minLon: Double, maxLat: Double, maxLon: Double)
     
    /// 중심 좌표 기준으로 주어진 반경(기본 500m)의 Bounding Box를 계산합니다.
    /// - Parameters:
    ///   - coordinate: 중심이 되는 지도 좌표
    ///   - radius: 반경 (미터 단위)
    /// - Returns: 위도/경도 최소/최대값을 담은 BoundingBox 튜플
    func boundingBoxFor(
        coordinate: MapCoordinate,
        radius: Double = 500
    ) -> BoundingBox {
        let metersPerDegreeLat = 111_320.0
        let deltaLat = radius / metersPerDegreeLat

        let latRad = coordinate.latitude * .pi / 180
        let metersPerDegreeLon = metersPerDegreeLat * cos(latRad)
        let deltaLon = metersPerDegreeLon == 0 ? 0 : radius / metersPerDegreeLon

        return (
            coordinate.latitude - deltaLat,
            coordinate.longitude - deltaLon,
            coordinate.latitude + deltaLat,
            coordinate.longitude + deltaLon
        )
    }
     
    /// 주소 기준으로 중복 Location을 하나로 통합합니다.
    /// 같은 주소가 여러 번 등장할 경우, 가장 마지막에 등장한 Location이 사용됩니다.
    /// - Parameter locations: 원본 Location 배열
    /// - Returns: 주소별로 하나씩만 남긴 Location 배열
    func uniqueLocations(_ locations: [Location]) -> [Location] {
        var dict: [String: Location] = [:]
         
        for loc in locations {
            dict[loc.address, default: loc] = loc
        }
         
        return Array(dict.values)
    }
     
    /// LocationType == 2(기지국)인 Location을 필터링하여 제거합니다.
    /// - Parameter locations: 원본 Location 배열
    /// - Returns: 기지국을 제외한 Location 배열
    func removeBaseStations(_ locations: [Location]) -> [Location] {
        locations.filter { $0.locationType != 2 }
    }
     
    /// 주어진 Location의 bounding box가 기준 BoundingBox와 겹치는지 확인합니다.
    /// (Location에 저장된 boxMin/boxMax 값이 없으면 false)
    /// - Parameters:
    ///   - loc: 검사할 Location
    ///   - bbox: 기준이 되는 BoundingBox
    /// - Returns: 두 영역이 겹치면 true, 아니면 false
    func isInsideBoundingBox(loc: Location, bbox: BoundingBox) -> Bool {
        guard let minLat = loc.boxMinLatitude,
              let minLon = loc.boxMinLongitude,
              let maxLat = loc.boxMaxLatitude,
              let maxLon = loc.boxMaxLongitude else { return false }

        // 하나라도 완전히 떨어져 있으면 겹치지 않는다고 판단
        if maxLat < bbox.minLat { return false }
        if minLat > bbox.maxLat { return false }
        if maxLon < bbox.minLon { return false }
        if minLon > bbox.maxLon { return false }

        return true
    }
}
