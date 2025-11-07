//
//  CameraView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct CameraView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: CameraFeature.State(),
        reducer: CameraFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testCamera)
    }
}

// MARK: - Extension Methods

extension CameraView {}

// MARK: - Private Extension Methods

private extension CameraView {}

// MARK: - Preview

#Preview {
    CameraView()
        .environment(AppCoordinator())
}
