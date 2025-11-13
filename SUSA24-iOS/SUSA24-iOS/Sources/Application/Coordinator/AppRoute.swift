//
//  AppRoute.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import Foundation

enum AppRoute: Hashable {
    case cameraScene(caseID: UUID)
    case caseAddScene
    case caseListScene
    case dashboardScene(caseID: UUID)
    case mainTabScene(caseID: UUID)
    case mapScene(caseID: UUID)
    case onePageScene(caseID: UUID)
    case searchScene
    case selectLocationScene
    case settingScene
    case scanLoadScene
    case photoDetailsScene(photos: [CapturedPhoto], camera: CameraModel)
    //    case timeLineScene
}

extension AppRoute {
    var useTabBar: Bool {
        switch self {
        // 보여주지 않을 화면들만 표시
        case .cameraScene, .photoDetailsScene,
             .scanLoadScene, .searchScene:
            false
        default:
            true
        }
    }
}
