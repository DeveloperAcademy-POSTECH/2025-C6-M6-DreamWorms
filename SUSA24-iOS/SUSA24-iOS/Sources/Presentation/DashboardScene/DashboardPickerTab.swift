//
//  DashboardPickerTab.swift
//  SUSA24-iOS
//
//  Created by mini on 11/3/25.
//

import SwiftUI

enum DashboardPickerTab: CaseIterable {
    case visitDuration, visitFrequency
    
    /// Picker에 사용될 타이틀 이름
    var title: String {
        switch self {
        case .visitDuration:
            String(localized: .visitDuration)
        case .visitFrequency:
            String(localized: .visitFrequency)
        }
    }
    
    /// SectionHeader에 사용될 타이틀 내용
    var sectionTitle: String {
        switch self {
        case .visitDuration:
            String(localized: .dashboardVisitDurationRankTitle)
        case .visitFrequency:
            String(localized: .dashboardVisitFreqRankTitle)
        }
    }
    
    /// SectionHeader에 사용될 설명 내용
    var sectionDescription: String {
        switch self {
        case .visitDuration:
            String(localized: .dashboardVisitDurationRankDescription)
        case .visitFrequency:
            String(localized: .dashboardVisitFreqRankDescription)
        }
    }
}
