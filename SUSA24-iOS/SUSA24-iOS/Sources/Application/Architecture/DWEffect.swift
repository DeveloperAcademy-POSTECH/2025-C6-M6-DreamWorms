//
//  DWEffect.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import Foundation

/// 비동기 사이드 이펙트(네트워크, 타이머, 파일 I/O 등)를 모델링합니다.
/// 작업이 완료되면 후속 `Action`을 방출하여 단방향 데이터 흐름을 유지합니다.
public struct DWEffect<Action: DWAction>: Sendable {
    
    /// Effect 실행 본문입니다. `downstream`에 후속 액션을 전달하면
    /// `Store`가 그 액션을 다시 `reduce` 흐름으로 연결합니다.
    public let run: @Sendable (@escaping @Sendable (Action) -> Void) async -> Void
    
    /// 새 이펙트를 생성합니다.
    /// - Parameter run: 후속 액션을 방출할 수 있는 비동기 본문.
    public init(_ run: @escaping @Sendable (@escaping @Sendable (Action) -> Void) async -> Void) { self.run = run }
    
    /// 수행할 작업이 없는 이펙트입니다.
    public static var none: DWEffect { .init { _ in } }
    
    /// 지정한 액션 하나를 즉시 방출하는 이펙트입니다.
    /// - Parameter action: 즉시 전파할 액션
    /// - Returns: 액션 하나를 즉시 전송하는 이펙트
    public static func send(_ action: Action) -> DWEffect {
        .init { downstream in
            downstream(action)
        }
    }
}
