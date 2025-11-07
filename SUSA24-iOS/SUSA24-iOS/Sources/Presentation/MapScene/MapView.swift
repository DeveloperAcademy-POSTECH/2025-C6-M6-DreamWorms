//
//  MapView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import NMapsMap
import SwiftUI

struct MapView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var store: DWStore<MapFeature>

    // MARK: - Properties
    
    // MARK: - View

    var body: some View {
        ZStack {
            NaverMapView(onMapTapped: { latlng in
                handleMapTap(latlng: latlng)
            })
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
                        },
                        iconImage: Image(MapFilterType.cellStationRange.iconName)
                    )
                    
                    MapFilterButton(
                        text: MapFilterType.visitFrequency.rawValue,
                        isActive: store.state.isVisitFrequencySelected,
                        action: {
                            store.send(.selectFilter(.visitFrequency))
                        },
                        iconImage: Image(MapFilterType.visitFrequency.iconName)
                    )
                    
                    MapFilterButton(
                        text: MapFilterType.recentBaseStation.rawValue,
                        isActive: store.state.isRecentBaseStationSelected,
                        action: {
                            store.send(.selectFilter(.recentBaseStation))
                        },
                        iconImage: Image(MapFilterType.recentBaseStation.iconName)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        MapLayerContainer(
                            isLayerActive: store.state.isMapLayerSheetPresented,
                            onLayerTapped: {
                                store.send(.toggleMapLayerSheet)
                            },
                            onRecenterTapped: nil
                        )
                        
                        DWGlassEffectCircleButton(
                            image: Image(.scan),
                            action: { coordinator.push(.cameraScene) }
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
        // TODO: 지도 레이어 시트 구현 (store.state.isMapLayerSheetPresented 사용)
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: Binding(
            get: { store.state.isPlaceInfoSheetPresented },
            set: { _ in store.send(.hidePlaceInfo) }
        )) {
            PlaceInfoSheet(
                placeInfo: store.state.selectedPlaceInfo ?? PlaceInfo(
                    title: "",
                    jibunAddress: "",
                    roadAddress: "",
                    phoneNumber: ""
                ),
                isLoading: store.state.isPlaceInfoLoading,
                onClose: { store.send(.hidePlaceInfo) }
            )
            .presentationDetents([.fraction(0.4)])
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Private Methods
    
    /// 맵 터치 시 좌표로 주소 정보를 조회합니다.
    private func handleMapTap(latlng: NMGLatLng) {
        store.send(.mapTapped(latlng))
    }
}

// MARK: - Preview

#Preview {
    let repository = MockLocationRepository()
    let store = DWStore(
        initialState: MapFeature.State(caseId: UUID()),
        reducer: MapFeature(repository: repository)
    )
    return MapView(store: store)
        .environment(AppCoordinator())
}
