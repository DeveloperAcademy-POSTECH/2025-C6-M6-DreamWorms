//
//  DWReducer.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import Foundation

/// 상태를 동기적으로 수정하고, 필요 시 비동기 사이드 이펙트를 반환하는 프로토콜입니다.
@MainActor
public protocol DWReducer {
    associatedtype State: DWState
    associatedtype Action: DWAction
    
    /// 액션을 받아 상태를 수정하고, 후속 이펙트를 반환합니다.
    /// - Parameters:
    ///   - state: **inout** 상태. 동기적으로만 수정해야 합니다.
    ///   - action: 처리할 액션
    /// - Returns: 후속 액션을 방출할 수 있는 `DWEffect`. 없으면 `.none` 반환
    func reduce(into state: inout State, action: Action) -> DWEffect<Action>
}
