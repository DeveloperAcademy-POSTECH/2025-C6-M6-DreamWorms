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
    // MARK: - State
    
    struct State: DWState {
        /// 케이스 정보
        var caseInfo: Case?
        /// Location 배열
        var locations: [Location]
        /// 날짜별로 그룹화된 Location
        var groupedLocations: [LocationGroupedByDate]
        
        var scrollTarget: ScrollTarget?
        
        /// Tabar 관련 보일 컨텐츠 영역잡기용
        var isMinimized: Bool = false
        
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
            let allLocations = groupedLocations.flatMap { $0.locations }
            let uniqueAddresses = Set(allLocations.map { $0.address })
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
        
        case setMinimized(Bool)
        
        /// 검색바 터치
        case searchTextChanged(String)
        
        /// 검색 시에 기능
        case setSearchActive(Bool)
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            // 탭바를 위한 조건
            state.isMinimized = false
            
            return .none
            
        case .locationTapped:
            // TODO: Location 상세 화면으로 이동 또는 지도에서 선택된 위치 표시
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
            
        case let .setMinimized(isMinimized):
            state.isMinimized = isMinimized
            return .none

        case let .searchTextChanged(text):
            state.searchText = text
            
            return .none
            
        case let .setSearchActive(isActive):
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
