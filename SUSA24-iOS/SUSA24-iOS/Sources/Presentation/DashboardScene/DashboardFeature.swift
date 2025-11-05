//
//  DashboardFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct DashboardFeature: DWReducer {
    
    private let repository: LocationRepositoryProtocol
    init(repository: LocationRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        var tab: DashboardPickerTab = .visitDuration
        var caseID: UUID? = nil
        var topVisitDurationLocations = [StayAddress]()
        var isLoadingTop = false
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case setTab(DashboardPickerTab)
        case onAppear(UUID)
        case setTopVisitDuration([StayAddress])
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
            
        case .setTab(let tab):
            state.tab = tab
            return .none
            
        case .onAppear(let caseID):
            state.caseID = caseID
            return .task { [repository] in
                do {
                    let locations = try await repository.fetchLocations(caseId: caseID)
                    let top3Locations = await topAddressStays(from: locations)
                    return .setTopVisitDuration(top3Locations)
                } catch {
                    return .none
                }
            }
            
        case .setTopVisitDuration(let visits):
            state.topVisitDurationLocations = visits
            return .none
        }
    }
}

// MARK: - Private Extensions

private extension DashboardFeature {
    /// 기지국 데이터(locationType == 2)를 대상으로, 주소별 체류시간(분)을 누적해 상위 K개 반환하는 메서드
    func topAddressStays(
        from locations: [Location],
        sampleMinutes: Int = 5,
        topK: Int = 3
    ) -> [StayAddress] {
        let filteredLocations = locations.filter { $0.locationType == 2 }
        var bucket: [String: Int] = [:]
        
        for location in filteredLocations {
            let key = location.address.isEmpty ? "기지국 주소" : location.address
            bucket[key, default: 0] += 1
        }

        let stays = bucket.map { StayAddress(address: $0.key, totalMinutes: $0.value * sampleMinutes) }
        return stays.sorted { $0.totalMinutes > $1.totalMinutes }.prefix(topK).map { $0 }
    }
}
