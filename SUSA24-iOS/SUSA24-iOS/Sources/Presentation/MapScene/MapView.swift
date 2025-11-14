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
    private let infrastructureManager: InfrastructureMarkerManager
    private let caseLocationMarkerManager: CaseLocationMarkerManager
    
    // MARK: - Initializer
    
    init(
        store: DWStore<MapFeature>,
        dispatcher: MapDispatcher,
        infrastructureManager: InfrastructureMarkerManager,
        caseLocationMarkerManager: CaseLocationMarkerManager
    ) {
        self._store = State(initialValue: store)
        self._dispatcher = Bindable(dispatcher)
        self.infrastructureManager = infrastructureManager
        self.caseLocationMarkerManager = caseLocationMarkerManager
    }
    
    // MARK: - View

    var body: some View {
        ZStack {
            NaverMapView(
                cameraTargetCoordinate: store.state.cameraTargetCoordinate,
                shouldFocusMyLocation: store.state.shouldFocusMyLocation,
                onCameraMoveConsumed: {
                    store.send(.clearCameraTarget)
                },
                onMyLocationFocusConsumed: {
                    store.send(.clearFocusMyLocationFlag)
                },
                onMapTapped: { latlng in store.send(.mapTapped(latlng)) },
                onCameraIdle: { bounds, zoomLevel in
                    store.send(.cameraIdle(bounds: bounds, zoomLevel: zoomLevel))
                },
                cellStations: store.state.cellStations,
                isCellLayerEnabled: store.state.isBaseStationLayerEnabled,
                locations: store.state.locations,
                isVisitFrequencyEnabled: store.state.isVisitFrequencySelected,
                isCellRangeVisible: store.state.isBaseStationRangeSelected,
                cellCoverageRange: store.state.mapLayerCoverageRange,
                cctvMarkers: store.state.cctvMarkers,
                isCCTVLayerEnabled: store.state.isCCTVLayerEnabled,
                infrastructureManager: infrastructureManager,
                caseLocationMarkerManager: caseLocationMarkerManager
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
                            onRecenterTapped: {
                                store.send(.requestFocusMyLocation)
                            }
                        )
                        
                        DWGlassEffectCircleButton(
                            image: Image(.scan),
                            // TODO: 작업이 안되어있어서 임시로 UUID 생성해서 넣음
                            action: {
                                if let caseId = store.state.caseId {
                                    coordinator.push(.cameraScene(caseID: caseId))
                                } else {
                                    coordinator.push(.cameraScene(caseID: UUID()))
                                }
                            }
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
        .onChange(of: dispatcher.request) { _, request in
            guard let request else { return }
            // 명령 디스패처가 발행한 지도 명령을 Reducer 흐름으로 전달합니다.
            switch request {
            case let .moveToSearchResult(coordinate, placeInfo):
                store.send(.moveToSearchResult(coordinate, placeInfo))
            }
        }
        .sheet(isPresented: Binding(
            get: { store.state.isMapLayerSheetPresented },
            set: { store.send(.setMapLayerSheetPresented($0)) }
        )) {
            MapLayerSettingSheet(
                selectedRange: Binding(
                    get: { store.state.mapLayerCoverageRange },
                    set: { store.send(.setMapLayerCoverage($0)) }
                ),
                isCCTVEnabled: Binding(
                    get: { store.state.isCCTVLayerEnabled },
                    set: { store.send(.setCCTVLayerEnabled($0)) }
                ),
                isBaseStationEnabled: Binding(
                    get: { store.state.isBaseStationLayerEnabled },
                    set: { store.send(.setBaseStationLayerEnabled($0)) }
                ),
                onClose: { store.send(.setMapLayerSheetPresented(false)) }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
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
