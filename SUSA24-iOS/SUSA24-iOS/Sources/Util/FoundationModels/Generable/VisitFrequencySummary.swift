//
//  VisitFrequencySummary.swift
//  SUSA24-iOS
//
//  Created by mini on 11/21/25.
//

import FoundationModels

@Generable
struct VisitFrequencySummary: Equatable {
    @Guide(description: "방문빈도 1위 자역에 대한 문장")
    let title: String
}
