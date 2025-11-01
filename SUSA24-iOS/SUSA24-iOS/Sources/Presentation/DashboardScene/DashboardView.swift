//
//  DashboardView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct DashboardView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: DashboardFeature.State(),
        reducer: DashboardFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testDashboard)
    }
}

// MARK: - Extension Methods

extension DashboardView {}

// MARK: - Private Extension Methods

private extension DashboardView {}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AppCoordinator())
}
