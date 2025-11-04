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
            
            VStack(alignment: .leading, spacing: 0) {
                MapHeader(
                    onBackTapped: { coordinator.pop() },
                    onSearchTapped: { coordinator.push(.searchScene) }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 10)
                
                HStack(spacing: 10) {
                    MapFilterButton(
                        text: MapFilterType.cellStationRange.rawValue,
                        isActive: store.state.isBaseStationRangeSelected,
                        action: {
                            store.send(.selectFilter(.cellStationRange))
                        }
                    )
                    .setupDefaultIcon(Image(MapFilterType.cellStationRange.iconName))
                    
                    MapFilterButton(
                        text: MapFilterType.visitFrequency.rawValue,
                        isActive: store.state.isVisitFrequencySelected,
                        action: {
                            store.send(.selectFilter(.visitFrequency))
                        }
                    )
                    .setupDefaultIcon(Image(MapFilterType.visitFrequency.iconName))
                    
                    MapFilterButton(
                        text: MapFilterType.recentBaseStation.rawValue,
                        isActive: store.state.isRecentBaseStationSelected,
                        action: {
                            store.send(.selectFilter(.recentBaseStation))
                        }
                    )
                    .setupDefaultIcon(Image(MapFilterType.recentBaseStation.iconName))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        MapLayerContainer()
                        
                        DWGlassEffectCircleButton(
                            action: { coordinator.push(.cameraScene) },
                            icon: Image(.scan)
                        )
                        .setupSize(48)
                        .setupIconSize(width: 25, height: 19)
                    }
                    .padding(.trailing, 16)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Preview

//#Preview {
//    let repository = MockLocationRepository()
//    let store = DWStore(
//        initialState: MapFeature.State(caseId: UUID()),
//        reducer: MapFeature(repository: repository)
//    )
//    return MapView(store: store)
//        .environment(AppCoordinator())
//}
