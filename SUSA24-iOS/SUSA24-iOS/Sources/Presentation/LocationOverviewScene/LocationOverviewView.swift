//
//  LocationOverviewView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/9/25.
//

import SwiftUI

struct LocationOverviewView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var store: DWStore<LocationOverviewFeature>
    
    // MARK: - Properties
    
    @State private var isMapExpanded: Bool = false
    @Namespace private var mapNamespace
    
    let caseID: UUID
    let baseAddress: String
    let initialCoordinate: MapCoordinate
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                MapPreviewView(
                    centerCoordinate: initialCoordinate,
                    locations: store.state.filteredLocations,
                    isExpanded: $isMapExpanded,
                    namespace: mapNamespace
                )
                .padding(.top, 26)
                .padding(.bottom, 24)
                .padding(.horizontal, 16)
                
                LocationOverviewListHeader(
                    selection: store.state.selection,
                    counts: store.state.counts,
                    onCategoryTap: { store.send(.selectionChanged($0)) }
                )
                .padding(.bottom, 12)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.state.filteredLocations) { item in
                            DWLocationCard(
                                type: .icon(LocationType(item.locationType).icon),
                                title: item.title ?? "타이틀",
                                description: item.address
                            )
                            .setupAsButton(false)
                            .setupIconBackgroundColor(PinColorType(item.colorType).color)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            if isMapExpanded {
                ExpandedMapView(
                    centerCoordinate: initialCoordinate,
                    locations: store.state.filteredLocations,
                    isExpanded: $isMapExpanded,
                    namespace: mapNamespace
                )
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .opacity
                    )
                )
                .zIndex(10)
            }
        }
        .navigationTitle(baseAddress)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            store.send(
                .onAppear(
                    caseID: caseID,
                    baseAddress: baseAddress,
                    initialCoordinate: initialCoordinate
                )
            )
        }
    }
}

// MARK: - Extension Methods

extension LocationOverviewView {}

// MARK: - Private Extension Methods

private extension LocationOverviewView {}

// MARK: - Preview

// #Preview {
//    let dummyStore = DWStore(
//        initialState: LocationOverviewFeature.State(
//            caseID: UUID(),
//            baseAddress: "기지국 주소",
//            selection: .all,
//            allLocations: [],
//            filteredLocations: [],
//            counts: [.all: 16, .residence: 2, .workplace: 1, .others: 13]
//        ),
//        reducer: LocationOverviewFeature(repository: MockLocationRepository())
//    )
//
//    NavigationStack {
//        LocationOverviewView(
//            store: dummyStore,
//            caseID: UUID(),
//            baseAddress: "기지국주소",
//            initialCoordinate: MapCoordinate(latitude: 0, longitude: 0)
//        )
//        .environment(AppCoordinator())
//    }
// }
