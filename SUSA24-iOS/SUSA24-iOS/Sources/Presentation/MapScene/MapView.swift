//
//  MapView.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//  Updated by taeni on 11/13/25.
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
    
    // MARK: - Active Sheet
    
    /// MapView 에서 사용하는 Sheet 종류
    private enum ActiveSheet: Identifiable, Equatable {
        case mapLayer(id: UUID)
        case placeInfo(id: UUID)
        case pinWrite(id: UUID)
        case memoEdit(id: UUID)
        
        var id: UUID {
            switch self {
            case let .mapLayer(id),
                 let .placeInfo(id),
                 let .pinWrite(id),
                 let .memoEdit(id):
                id
            }
        }
        
        static func == (lhs: ActiveSheet, rhs: ActiveSheet) -> Bool {
            lhs.id == rhs.id
        }
    }
    
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
                shouldAnimateCameraTarget: store.state.shouldAnimateCameraTarget,
                cameraTargetZoomLevel: store.state.cameraTargetZoomLevel,
                shouldFocusMyLocation: store.state.shouldFocusMyLocation,
                onCameraMoveConsumed: {
                    store.send(.clearCameraTarget)
                },
                onMyLocationFocusConsumed: {
                    store.send(.clearFocusMyLocationFlag)
                },
                onCellMarkerTapped: { cellKey, title in
                    // cellKey 파싱: "latitude_longitude" 형식 → MapCoordinate
                    let components = cellKey.split(separator: "_")
                    if components.count == 2,
                       let lat = Double(components[0]),
                       let lng = Double(components[1])
                    {
                        let coordinate = MapCoordinate(latitude: lat, longitude: lng)
                        store.send(.moveToLocation(coordinate))
                    }
                    dispatcher.send(.focusCellTimeline(cellKey: cellKey, title: title))
                },
                onUserLocationMarkerTapped: { locationId in
                    store.send(.userLocationMarkerTapped(locationId))
                },
                isTimelineSheetPresented: store.state.isTimelineSheetPresented,
                isPlaceInfoSheetPresented: store.state.isPlaceInfoSheetPresented,
                onMapTapped: { latlng in
                    // MapFeature에서 타임라인 시트 상태를 체크하여 처리
                    store.send(.mapTapped(latlng))
                },
                deselectMarkerTrigger: store.state.deselectMarkerTrigger,
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
                idlePinCoordinate: store.state.idlePinCoordinate,
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
        .task {
            store.send(.loadCellStations)
            store.send(.startObservingLocations)
        }
        .onChange(of: dispatcher.request) { _, request in
            guard let request else { return }
            switch request {
            case let .moveToSearchResult(coordinate, placeInfo):
                store.send(.moveToSearchResult(coordinate, placeInfo))
            case let .moveToLocation(coordinate):
                store.send(.moveToLocation(coordinate))
            case .focusCellTimeline:
                // Timeline 전용 요청은 MapView에서는 처리하지 않습니다.
                break
            }
        }
        .sheet(isPresented: isMapPanelPresentedBinding) {
            MapSheetPanel(
                state: store.state,
                send: store.send
            )
            .presentationDetents(currentDetents)
            .presentationDragIndicator(.visible)
            .presentationDragIndicator(.hidden)
            .presentationBackgroundInteraction(store.state.isPlaceInfoSheetPresented ? .enabled : .disabled)
        }
    }
}

private extension MapView {
    /// Map 전용 패널(MapSheetPanel)을 위한 표시 여부 바인딩
    var isMapPanelPresentedBinding: Binding<Bool> {
        Binding(
            get: { store.state.isAnyMapBottomPanelVisible },
            set: { newValue in
                if newValue == false {
                    store.send(.setMapLayerSheetPresented(false))
                    store.send(.hidePlaceInfo())
                    store.send(.closePinWrite)
                    store.send(.closeMemoEdit)
                }
            }
        )
    }
    
    /// 현재 열려있는 패널 종류에 따라 다른 detent 세트를 리턴
    var currentDetents: Set<PresentationDetent> {
        let state = store.state
        
        if state.isMapLayerSheetPresented {
            return [.height(410)]
        } else if state.isPlaceInfoSheetPresented {
            return [state.hasExistingPin ? .height(416) : .height(294)]
        } else if state.isPinWritePresented {
            return [.height(620)]
        } else if state.isMemoEditPresented {
            return [.large]
        } else {
            return [.medium]
        }
    }
}
