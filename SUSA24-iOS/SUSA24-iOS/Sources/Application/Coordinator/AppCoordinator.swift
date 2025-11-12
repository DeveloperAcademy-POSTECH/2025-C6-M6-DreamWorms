//
//  AppCoordinator.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import Combine
import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()
    private var routes: [AppRoute] = []
    private(set) var currentRoute: AppRoute?

    func push(_ route: AppRoute) {
        path.append(route)
        routes.append(route)
        syncRoute()
    }

    func pop() {
        path.removeLast()
        if !routes.isEmpty {
            routes.removeLast()
        }
        syncRoute()
    }

    func popToRoot() {
        path.removeLast(path.count)
        routes.removeAll()
        syncRoute()
    }
    
    func popToDepth(_ depth: Int) {
        path.removeLast(depth)
        if routes.count >= depth {
            routes.removeLast(depth)
        }
        syncRoute()
    }

    func replaceLast(_ route: AppRoute) {
        if !routes.isEmpty {
            path.removeLast()
            routes.removeLast()
        }
        path.append(route)
        routes.append(route)
        syncRoute()
    }

    private func syncRoute() {
        currentRoute = routes.last
    }
}
