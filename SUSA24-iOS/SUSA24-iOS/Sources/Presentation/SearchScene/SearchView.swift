//
//  SearchView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: SearchFeature.State(),
        reducer: SearchFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testSearch)
    }
}

// MARK: - Extension Methods

extension SearchView {}

// MARK: - Private Extension Methods

private extension SearchView {}

// MARK: - Preview

#Preview {
    SearchView()
        .environment(AppCoordinator())
}
