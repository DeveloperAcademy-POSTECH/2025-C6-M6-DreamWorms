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
    var paths: [AppRoute] = []

    func push(_ route: AppRoute) {
        paths.append(route)
    }

    func pop() {
        paths.removeLast()
    }

    func popToRoot() {
        paths.removeLast(paths.count)
    }
    
    func popToDepth(_ depth: Int) {
        paths.removeLast(depth)
    }
}
