//
//  AppCoordinator.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func popToDepth(_ depth: Int) {
        path.removeLast(depth)
    }
}
