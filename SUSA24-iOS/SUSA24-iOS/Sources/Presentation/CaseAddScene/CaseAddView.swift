//
//  CaseAddView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct CaseAddView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies

    @State private var store = DWStore(
        initialState: CaseAddFeature.State(),
        reducer: CaseAddFeature()
    )
    
    // MARK: - Properties

    // MARK: - View

    var body: some View {
        Text(.testCaseAdd)
    }
}

// MARK: - Extension Methods

extension CaseAddView {}

// MARK: - Private Extension Methods

private extension CaseAddView {}

// MARK: - Preview

#Preview {
    CaseAddView()
        .environment(AppCoordinator())
}
