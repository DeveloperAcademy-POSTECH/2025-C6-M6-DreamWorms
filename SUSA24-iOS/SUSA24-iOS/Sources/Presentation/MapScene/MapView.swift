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
    
    @State var store: DWStore<MapFeature>

    // MARK: - Properties
    
    // MARK: - View

    var body: some View {
        ZStack {
            NaverMapView()
                .ignoresSafeArea()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Extension Methods

extension MapView {}

// MARK: - Private Extension Methods

private extension MapView {}

// MARK: - Preview

//#Preview {
//    let repository = MockLocationRepository()
//    let store = DWStore(
//        initialState: MapFeature.State(),
//        reducer: MapFeature(repository: repository)
//    )
//    return MapView(store: store)
//        .environment(AppCoordinator())
//}
