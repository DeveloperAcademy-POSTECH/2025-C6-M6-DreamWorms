//
//  SettingView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct SettingView: View {
    
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

extension SettingView {}

// MARK: - Private Extension Methods

private extension SettingView {}

// MARK: - Preview

#Preview {
    SettingView()
        .environment(AppCoordinator())
}
