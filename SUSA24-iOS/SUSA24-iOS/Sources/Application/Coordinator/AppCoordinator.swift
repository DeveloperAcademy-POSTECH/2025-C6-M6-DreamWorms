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

    /// 다음 화면으로 넘어갈 때 사용하는 메서드 (_ route 부분에 전환하고자 하는 다음 화면 명시)
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    /// 이전 화면으로 돌아갈 때 사용하는 메서드
    func pop() {
        path.removeLast()
    }
    
    /// path에 쌓여있는 모든 화면을 지우고, 루트로 돌아가도록 하는 메서드
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    /// 현재 화면을 새로운 화면으로 바꿀 때 사용하는 메서드
    func replaceLast(_ route: AppRoute) {
        if !path.isEmpty { path.removeLast() }
        path.append(route)
    }
}
