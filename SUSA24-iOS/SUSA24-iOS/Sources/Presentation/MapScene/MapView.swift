//
//  MapView.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//

import NMapsMap
import SwiftUI

/// 네이버 지도와 위치 정보 시트를 함께 렌더링하고, 명령 디스패처(MapDispatcher)의 요청을 소비해 지도 이동/시트 갱신을 수행하는 메인 지도 화면입니다.
struct MapView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store: DWStore<MapFeature>
    @Bindable private var dispatcher: MapDispatcher
    
    // MARK: - Properties
    
    // MARK: - Initializer
    
    init(store: DWStore<MapFeature>, dispatcher: MapDispatcher) {
        self._store = State(initialValue: store)
        self._dispatcher = Bindable(dispatcher)
    }
    
    // MARK: - View

    var body: some View {
        ZStack {
            NaverMapView(
                targetCoordinate: store.state.targetCoordinate,
                onMoveConsumed: {
                    // 지도 카메라 이동이 완료되었으므로 상태의 명령을 초기화합니다.
                    store.send(.consumeTargetCoordinate)
                },
                onMapTapped: { latlng in handleMapTap(latlng: latlng) }
            )
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
        .onChange(of: dispatcher.request) { _, request in
            guard let request else { return }
            // 명령 디스패처가 발행한 지도 명령을 Reducer 흐름으로 전달합니다.
            switch request {
            case let .moveToSearchResult(coordinate, placeInfo):
                store.send(.moveToSearchResult(coordinate, placeInfo))
            }
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
            .presentationDragIndicator(.hidden)
        }
    }
    
    // MARK: - Private Methods
    
    /// 지도에서 탭 이벤트를 받으면 해당 좌표로 상세 정보를 조회하도록 `MapFeature`에 액션을 전달합니다.
    private func handleMapTap(latlng: NMGLatLng) {
        store.send(.mapTapped(latlng))
    }
}

// MARK: - Preview

// #Preview {
//    let repository = MockLocationRepository()
//    let store = DWStore(
//        initialState: MapFeature.State(caseId: UUID()),
//        reducer: MapFeature(repository: repository, dispatcher: MapDispatcher())
//    )
//    return MapView(
//        store: store,
//        dispatcher: MapDispatcher()
//    )
//        .environment(AppCoordinator())
// }
