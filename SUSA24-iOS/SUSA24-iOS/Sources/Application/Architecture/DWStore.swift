//
//  DWStore.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

@MainActor
@Observable
public final class DWStore<R: DWReducer> {
    public private(set) var state: R.State
    private let reducer: R

    public init(initialState: R.State, reducer: R) {
        self.state = initialState
        self.reducer = reducer
    }

    public func send(_ action: R.Action) {
        let effect = reducer.reduce(into: &state, action: action)

        Task { [weak self] in
            guard let self else { return }
            await effect.run { [weak self] next in
                Task { @MainActor [weak self] in
                    self?.send(next)
                }
            }
        }
    }
}
