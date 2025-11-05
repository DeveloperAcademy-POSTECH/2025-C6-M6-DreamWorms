//
//  AppRoute.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import Foundation

enum AppRoute: Hashable {
    case cameraScene
    case caseAddScene
    case caseListScene
    case dashboardScene(caseID: UUID)
    case mainTabScene(caseID: UUID)
    case mapScene(caseID: UUID)
    case onePageScene(caseID: UUID)
    case searchScene
    case selectLocationScene
    case settingScene
    case timeLineScene
}
