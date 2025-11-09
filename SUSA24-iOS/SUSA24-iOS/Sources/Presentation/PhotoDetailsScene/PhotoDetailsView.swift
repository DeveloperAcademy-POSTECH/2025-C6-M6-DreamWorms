//
//  ScanLoadFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/31/25.
//

import SwiftUI

struct PhotoDetailsView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: PhotoDetailsFeature.State(),
        reducer: PhotoDetailsFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text("PhotoDetailsView")
    }
}

// MARK: - Extension Methods

extension PhotoDetailsView {}

// MARK: - Private Extension Methods

private extension PhotoDetailsView {}

// MARK: - Preview

//#Preview {
//    PhotoDetailsView()
//        .environment(AppCoordinator())
//}
