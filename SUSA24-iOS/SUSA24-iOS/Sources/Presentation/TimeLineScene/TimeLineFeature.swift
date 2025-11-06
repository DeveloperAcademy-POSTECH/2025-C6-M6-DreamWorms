//
//  TimeLineFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct TimeLineFeature: DWReducer {
    
    // MARK: - State
    
    struct State: DWState {
        /// 케이스 정보
        var caseInfo: Case?
        /// Location 배열
        var locations: [Location]
        /// 날짜별로 그룹화된 Location
        var groupedLocations: [LocationGroupedByDate] = []
        
        
        /// 케이스 이름
        var caseName: String {
            caseInfo?.name ?? ""
        }
        /// 용의자 이름
        var suspectName: String {
            caseInfo?.suspect ?? ""
        }
        /// 데이터가 비어있는지 여부
        var isEmpty: Bool {
            groupedLocations.isEmpty
        }
        
        /// 총 Location 개수
        var totalLocationCount: Int {
            groupedLocations.reduce(0) { $0 + $1.locations.count}
        }
        
        /// 초기화 - MainTabFeature.State에서 데이터를 받음
        /// - Parameters:
        ///     - caseInfo: 케이스 정보
        ///     - locations: Location 배열
        init(caseInfo: Case?, locations: [Location]) {
            self.caseInfo = caseInfo
            self.locations = locations
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 화면이 나타날 때 데이터 그룹화
        case onAppear
        /// Location 탭 이벤트
        case locationTapped(Location)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            // Location을 날짜별로 그룹화
            state.groupedLocations = LocationGroupedByDate.groupByDate(state.locations)
            return .none
        
        case .locationTapped:
            // TODO: Location 상세 화면으로 이동 또는 지도에서 선택된 위치 표시
            return .none
        }
    }
}
