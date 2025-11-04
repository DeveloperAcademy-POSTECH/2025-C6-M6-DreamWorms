//
//  MapFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct MapFeature: DWReducer {
    
    private let repository: LocationRepositoryProtocol
    
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - State
    
    struct State: DWState {
        var locations: [Location] = []
        var caseId: UUID?
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear
        case loadLocations([Location])
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            guard let caseId = state.caseId else { return .none }
            return .task { [repository] in
                do {
                    // NOTE: 테스트용 목데이터 저장 로직
                    // 케이스 선택 시 해당 케이스의 빈 문자열("") suspect에 Location 목데이터 저장
                    // 실제 데이터가 없을 경우를 대비한 테스트 데이터
                    // 프로토콜에는 포함되지 않으므로 타입 캐스팅 사용
                    if let locationRepository = repository as? LocationRepository {
                        try await locationRepository.loadMockDataIfNeeded(caseId: caseId)
                    }
                    
                    let locations = try await repository.fetchLocations(caseId: caseId)
                    return .loadLocations(locations)
                } catch {
                    return .none
                }
            }
            
        case .loadLocations(let locations):
            state.locations = locations
            return .none
        }
    }
}
