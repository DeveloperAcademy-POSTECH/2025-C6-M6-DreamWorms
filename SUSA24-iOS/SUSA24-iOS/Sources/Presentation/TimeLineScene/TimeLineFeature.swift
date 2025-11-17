//
//  TimeLineFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

// MARK: - ScrollTarget Model

/// 스크롤 타겟을 나타내는 모델
/// String ID를 사용하여 Date 객체 비교 문제를 해결합니다.
struct ScrollTarget: Equatable {
    let dateID: String // "2025-01-06" 형식
    let triggerID = UUID() // 같은 날짜를 여러 번 탭해도 스크롤되도록

    static func == (lhs: ScrollTarget, rhs: ScrollTarget) -> Bool {
        lhs.triggerID == rhs.triggerID
    }
}

struct TimeLineFeature: DWReducer {
    private let dispatcher: MapDispatcher

    init(dispatcher: MapDispatcher) {
        self.dispatcher = dispatcher
    }

    // MARK: - State
    
    struct State: DWState {
        /// 케이스 정보
        var caseInfo: Case?
        /// Location 배열
        var locations: [Location]
        /// 날짜별로 그룹화된 Location
        var groupedLocations: [LocationGroupedByDate]
        /// 기지국 셀 타임라인 모드 여부
        var isCellTimelineMode: Bool = false
        /// 셀 타임라인 모드일 때 헤더에 표시할 타이틀 (기지국 주소)
        var cellTimelineTitle: String?
        
        var scrollTarget: ScrollTarget?
        
        /// 검색 관련 State
        var searchText: String = ""
        var isSearchActive: Bool = false
        
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
        
        /// 고유한 장소(주소) 개수 - 맵에 찍힌 핀 개수
        var totalLocationCount: Int {
            let allLocations = groupedLocations.flatMap(\.locations)
            let uniqueAddresses = Set(allLocations.map(\.address))
            return uniqueAddresses.count
        }
        
        /// 초기화 - MainTabFeature.State에서 데이터를 받음
        /// - Parameters:
        ///     - caseInfo: 케이스 정보
        ///     - locations: Location 배열
        init(caseInfo: Case?, locations: [Location]) {
            self.caseInfo = caseInfo
            self.locations = locations
            self.groupedLocations = LocationGroupedByDate.groupByDate(locations)
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 화면이 나타날 때 데이터 그룹화
        case onAppear
        /// Location 탭 이벤트
        case locationTapped(Location)
        
        case scrollToDate(Date)
        
        case resetScrollTarget
        
        case updateData(caseInfo: Case?, locations: [Location])
        /// 선택한 셀에 해당하는 타임라인을 표시하도록 필터를 적용합니다.
        /// - Parameters:
        ///   - cellKey: 좌표 키 (latitude_longitude 형식)
        ///   - title: 헤더에 표시할 기지국 주소
        case applyCellFilter(cellKey: String, title: String?)
        /// 셀 타임라인 필터를 해제하고 전체 타임라인을 표시합니다.
        case clearCellFilter
        
        /// 검색바 터치
        case searchTextChanged(String)
        
        /// 검색 시에 기능
        case setSearchActive(Bool)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            return .none
            
        case let .locationTapped(location):
            // Timeline 셀 탭 시 맵으로 카메라 이동
            let coordinate = MapCoordinate(
                latitude: location.pointLatitude,
                longitude: location.pointLongitude
            )
            NotificationCenter.default.post(name: .resetDetentToMid, object: nil)
            dispatcher.send(.moveToLocation(coordinate: coordinate))
            return .none
            
        case let .scrollToDate(date):
            // Date를 String ID로 변환
            let dateID = Self.dateToID(date)
            
            // 매번 새로운 ScrollTarget 생성 (같은 날짜여도 스크롤 동작)
            state.scrollTarget = ScrollTarget(dateID: dateID)
            
            // 다음 프레임에서 초기화
            return .task {
                try? await Task.sleep(for: .seconds(0.1))
                return .resetScrollTarget
            }
            
        case .resetScrollTarget:
            state.scrollTarget = nil
            return .none
            
        case let .updateData(caseInfo, locations):
            state.caseInfo = caseInfo
            state.locations = locations
            state.groupedLocations = LocationGroupedByDate.groupByDate(locations)
            return .none

        case let .searchTextChanged(text):
            state.searchText = text
            
            return .none
            
        case let .setSearchActive(isActive):
            // TODO: 검색 활성/비활성 상태에 따라 필터 로직이 추가되면 연결
            return .none
            
        case let .applyCellFilter(cellKey, title):
            // 셀 타임라인 모드로 전환하고, 선택한 셀에 해당하는 Location만 필터링
            state.isCellTimelineMode = true
            let filtered = state.locations.filter { location in
                guard LocationType(location.locationType) == .cell else { return false }
                let key = MapCoordinate(
                    latitude: location.pointLatitude,
                    longitude: location.pointLongitude
                ).coordinateKey
                return key == cellKey
            }
            // 타이틀이 명시되지 않았다면, 필터된 Location 중 하나의 주소를 사용합니다.
            if state.cellTimelineTitle == nil {
                state.cellTimelineTitle = title ?? filtered.first?.address
            }
            state.groupedLocations = LocationGroupedByDate.groupByDate(filtered)
            return .none
            
        case .clearCellFilter:
            // 셀 타임라인 모드를 해제하고 전체 타임라인으로 복구
            state.isCellTimelineMode = false
            state.cellTimelineTitle = nil
            state.groupedLocations = LocationGroupedByDate.groupByDate(state.locations)
            return .none
        }
    }

    // MARK: - Helper

    /// Date를 String ID로 변환 ("2025-01-06" 형식)
    static func dateToID(_ date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day
        else {
            return ""
        }
        
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
