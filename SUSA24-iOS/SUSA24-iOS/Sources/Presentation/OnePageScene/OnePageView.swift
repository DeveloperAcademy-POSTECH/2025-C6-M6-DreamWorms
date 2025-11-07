//
//  OnePageView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct OnePageView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: OnePageFeature.State(),
        reducer: OnePageFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testOnePage)
    }
}

// MARK: - Extension Methods

extension OnePageView {}

// MARK: - Private Extension Methods

private extension OnePageView {}

// MARK: - Preview

#Preview {
    OnePageView()
        .environment(AppCoordinator())
}
