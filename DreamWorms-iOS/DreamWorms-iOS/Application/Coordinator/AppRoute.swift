//
//  AppRoute.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import Foundation

enum AppRoute: Hashable {
    case caseList
    case caseAdd
    case map(selectedCase: Case)
    case search
}

// TODO: - 만약 Case 타이틀이랑 겹치는것이 있다는 가정하에 id로 구분지을려면 TODO해야함
