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
    
    /// 비동기 작업을 수행한 뒤, 결과로 `Action?`을 방출하는 이펙트를 생성합니다.
    ///
    /// - Parameter work: 비동기 작업을 수행하는 클로저.
    /// - Returns: 작업 완료 후 액션을 전파하는 이펙트.
    ///
    public static func task(_ work: @escaping @Sendable () async -> Action?) -> Self {
        .init { downstream in
            if let a = await work() { downstream(a) }
        }
    }
    
    /// 여러 개의 이펙트를 동시에 실행하여, 각각이 방출하는 액션들을 모두 전달합니다.
    ///
    /// - Parameter effects: 동시에 실행할 여러 `DWEffect` 인스턴스.
    /// - Returns: 주어진 모든 이펙트를 병렬 실행하는 새로운 `DWEffect`.
    ///
    /// 이 메서드는 내부적으로 `withTaskGroup`을 사용하여 모든 이펙트를 병렬 실행합니다.
    /// 각 이펙트가 방출한 액션은 `Store`로 즉시 전파되어 reducer에 전달됩니다.
    public static func merge(_ effects: DWEffect<Action>...) -> DWEffect<Action> {
        .init { downstream in
            await withTaskGroup(of: Void.self) { group in
                for effect in effects {
                    group.addTask {
                        await effect.run(downstream)
                    }
                }
            }
        }
    }
}
