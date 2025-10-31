//
//  MapView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI
import NMapsMap

struct MapView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: MapFeature.State(),
        reducer: MapFeature()
    )

    // MARK: - Properties
    
    // MARK: - View

    var body: some View {
        ZStack {
            NaverMapView()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Extension Methods

extension MapView {}

// MARK: - Private Extension Methods

private extension MapView {}

// MARK: - Preview

#Preview {
    MapView()
        .environment(AppCoordinator())
}
