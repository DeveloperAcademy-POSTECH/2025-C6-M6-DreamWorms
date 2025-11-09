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
    
    let caseID: UUID
    let baseAddress: String

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            // TODO: - 지도화면 연결 이후 수정
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.mainAlternative)
                .frame(height: 206)
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
        .navigationTitle(baseAddress)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            store.send(.onAppear(caseID: caseID, baseAddress: baseAddress))
        }
    }
}

// MARK: - Extension Methods

extension LocationOverviewView {}

// MARK: - Private Extension Methods

private extension LocationOverviewView {}

// MARK: - Preview

//#Preview {
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
//            baseAddress: "기지국주소"
//        )
//        .environment(AppCoordinator())
//    }
//}
