//
//  SelectLocationView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct SelectLocationView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: SelectLocationFeature.State(),
        reducer: SelectLocationFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testSelectLocation)
    }
}

// MARK: - Extension Methods

extension SelectLocationView {}

// MARK: - Private Extension Methods

private extension SelectLocationView {}

// MARK: - Preview

#Preview {
    SelectLocationView()
        .environment(AppCoordinator())
}
