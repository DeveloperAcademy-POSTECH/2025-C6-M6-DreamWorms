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
        case onAppear(caseID: UUID, baseAddress: String)
        case selectionChanged(Category)
        case setLocations([Location])
        case refreshFilterAndCounts
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .onAppear(caseID, baseAddress):
            state.caseID = caseID
            state.baseAddress = baseAddress

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
            var counts: [Category: Int] = [:]
            for category in Category.allCases {
                let types = category.types
                counts[category] = state.allLocations.filter { loc in
                    types.contains(Int(loc.locationType))
                }.count
            }
            state.counts = counts

            let selectedTypes = state.selection.types

            state.filteredLocations = state.allLocations.filter { loc in
                guard selectedTypes.contains(Int(loc.locationType)) else { return false }
                if !state.baseAddress.isEmpty {
                    return loc.address == state.baseAddress
                }
                return true
            }

            return .none
        }
    }
}
