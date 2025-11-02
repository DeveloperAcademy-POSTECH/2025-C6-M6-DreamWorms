//
//  TimeLineView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct TimeLineView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: TimeLineFeature.State(),
        reducer: TimeLineFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testTimeline)
    }
}

// MARK: - Extension Methods

extension TimeLineView {}

// MARK: - Private Extension Methods

private extension TimeLineView {}

// MARK: - Preview

#Preview {
    TimeLineView()
        .environment(AppCoordinator())
}
