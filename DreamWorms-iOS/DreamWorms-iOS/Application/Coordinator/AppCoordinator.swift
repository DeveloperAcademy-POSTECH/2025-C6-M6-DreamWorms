//
//  AppCoordinator.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import Combine
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path: [AppRoute] = []

    /// 다음 화면으로 넘어갈 때 사용하는 메서드 (_ route 부분에 전환하고자 하는 다음 화면 명시)
    func push(_ route: AppRoute) {
        path.append(route)
    }

    /// 이전 화면으로 돌아갈 때 사용하는 메서드
    func pop(_ steps: Int = 1) {
        guard steps > 0, !path.isEmpty else { return }
        let stepsToRemove = min(steps, path.count)
        path.removeLast(stepsToRemove)
    }

    /// path에 쌓여있는 모든 화면을 지우고, 루트로 돌아가도록 하는 메서드
    func popToRoot() {
        path.removeLast(path.count)
    }

    /// 현재 화면을 새로운 화면으로 바꿀 때 사용하는 메서드
    func replaceLast(with route: AppRoute) {
        if !path.isEmpty {
            path.removeLast()
        }
        path.append(route)
    }
}
