//
//  VisitDurationSummary.swift
//  SUSA24-iOS
//
//  Created by mini on 11/16/25.
//

import FoundationModels

@Generable
struct VisitDurationSummary: Equatable {
    @Guide(description: "체류시간 1위 지역에 대한 문장")
    let title: String
}
