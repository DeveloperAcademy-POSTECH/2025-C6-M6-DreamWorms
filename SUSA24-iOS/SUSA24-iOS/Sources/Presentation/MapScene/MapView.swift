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
        infrastructureManager: InfrastructureMarkerManager
    ) {
        self._store = State(initialValue: store)
        self._dispatcher = Bindable(dispatcher)
        self.infrastructureManager = infrastructureManager
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
                onMapTapped: { latlng in
                    store.send(.mapTapped(latlng))
                },
                onCameraIdle: { bounds, zoomLevel in
                    store.send(.cameraIdle(bounds: bounds, zoomLevel: zoomLevel))
                },
                cellStations: store.state.cellStations,
                isCellLayerEnabled: store.state.isBaseStationLayerEnabled,
                cctvMarkers: store.state.cctvMarkers,
                isCCTVLayerEnabled: store.state.isCCTVLayerEnabled,
                infrastructureManager: infrastructureManager
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
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: dispatcher.request) { _, request in
            guard let request else { return }
            switch request {
            case let .moveToSearchResult(coordinate, placeInfo):
                store.send(.moveToSearchResult(coordinate, placeInfo))
            }
        }

        // MARK: - sheet(item:)로 통합

        .overlay {
            MapSheetContainer(
                state: store.state,
                send: store.send,
                createToolbarItems: { createToolbarItems() }
            )
        }
    }
    
    // MARK: - Private Methods
    
    // TODO: 로직 더 효율있게 바꿀 것. 버튼의 상태 값에 따라 구분하도록 수정해야함.
    private func createToolbarItems() -> [DWBottomToolbarItem] {
        if store.state.hasExistingPin {
            // 핀이 있는 경우: pin.fill + ellipsis (메뉴)
            [
                .button(image: Image(systemName: "pin.fill"), action: {
                    // 핀이 이미 있으므로 아무 동작 안함
                })
                .iconSize(16)
                .setupPadding(top: 4, leading: 6, bottom: 4, trailing: 3),
                
                .menu(
                    image: Image(systemName: "ellipsis"),
                    items: [
                        DWBottomToolbarItem.MenuItem(
                            title: String(localized: .buttonEdit),
                            systemImage: "pencil",
                            role: nil,
                            action: { store.send(.editPinTapped) }
                        ),
                        DWBottomToolbarItem.MenuItem(
                            title: String(localized: .buttonDelete),
                            systemImage: "trash",
                            role: .destructive,
                            action: { store.send(.showDeleteAlert) }
                        ),
                    ]
                )
                .iconSize(16)
                .setupPadding(top: 4, leading: 3, bottom: 4, trailing: 6),
            ]
        } else {
            // 핀이 없는 경우: pin만 표시
            [
                .button(image: Image(.pin), action: {
                    store.send(.addPinTapped)
                })
                .iconSize(16)
                .setupPadding(top: 4, leading: 6, bottom: 4, trailing: 3),
                .menu(
                    image: Image(.ellipsis),
                    items: [
                        DWBottomToolbarItem.MenuItem(
                            title: String(localized: .buttonShare),
                            systemImage: "square.and.arrow.up",
                            role: nil,
                            action: {}
                        ),
                    ]
                )
                .iconSize(16),
            ]
        }
    }
}
