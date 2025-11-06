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
    let dateID: String  // "2025-01-06" 형식
    let triggerID = UUID()  // 같은 날짜를 여러 번 탭해도 스크롤되도록
    
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
        var groupedLocations: [LocationGroupedByDate] = []
        
        var scrollTarget: ScrollTarget? = nil
        
        
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
        
        case scrollToDate(Date)
        
        case resetScrollTarget
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
            
        case .scrollToDate(let date):
            // Date를 String ID로 변환
            let dateID = Self.dateToID(date)
            
            // 매번 새로운 ScrollTarget 생성 (같은 날짜여도 스크롤 동작)
            state.scrollTarget = ScrollTarget(dateID: dateID)
            
            // 다음 프레임에서 초기화
            return .task {
                try? await Task.sleep(nanoseconds: 100_000_000)
                return .resetScrollTarget
            }
            
        case .resetScrollTarget:
            state.scrollTarget = nil
            return .none
        }
    }
    //MARK: - Helper
    /// Date를 String ID로 변환 ("2025-01-06" 형식)
    static func dateToID(_ date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return ""
        }
        
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
