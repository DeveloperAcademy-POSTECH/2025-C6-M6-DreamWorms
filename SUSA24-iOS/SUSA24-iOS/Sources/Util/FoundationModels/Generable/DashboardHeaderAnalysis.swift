//
//  DashboardHeaderAnalysis.swift
//  SUSA24-iOS
//
//  Created by mini on 11/16/25.
//

import FoundationModels

@Generable
struct DashboardHeaderAnalysis: Equatable {
    /// 체류시간 탭 문장
    let visitDurationSummary: String
    /// 방문빈도 탭 문장
    let visitFrequencySummary: String
}
