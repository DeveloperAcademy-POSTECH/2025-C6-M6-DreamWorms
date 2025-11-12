//
//  ScanLoadView.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/31/25.
//

import SwiftUI

struct ScanLoadView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: ScanLoadFeature.State(),
        reducer: ScanLoadFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text("ScanLoad")
    }
}

// MARK: - Extension Methods

extension ScanLoadView {}

// MARK: - Private Extension Methods

private extension ScanLoadView {}

// MARK: - Preview

// #Preview {
//    ScanLoadView()
//        .environment(AppCoordinator())
// }
