//
//  LocationOverviewView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/9/25.
//

import SwiftUI

struct LocationOverviewView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: SettingFeature.State(),
        reducer: SettingFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testSetting)
    }
}

// MARK: - Extension Methods

extension LocationOverviewView {}

// MARK: - Private Extension Methods

private extension LocationOverviewView {}

// MARK: - Preview

#Preview {
    LocationOverviewView()
        .environment(AppCoordinator())
}
