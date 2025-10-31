//
//  CaseListView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct CaseListView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: CaseListFeature.State(),
        reducer: CaseListFeature()
    )

    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testCaseList)
            .onTapGesture {
                coordinator.push(.mainTabScene)
            }
    }
}

// MARK: - Extension Methods

extension CaseListView {}

// MARK: - Private Extension Methods

private extension CaseListView {}

// MARK: - Preview

#Preview {
    CaseListView()
        .environment(AppCoordinator())
}
