//
//  PhotoDetailsView.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/29/25.
//

import SwiftUI

struct PhotoDetailsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var store: DWStore<PhotoDetailsFeature>
    
    @State private var screenSize: CGSize = .zero
    
    init(store: DWStore<PhotoDetailsFeature>) {
        _store = State(initialValue: store)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: Binding(
                get: {
                    store.state.photos.indices.contains(store.state.currentIndex)
                        ? store.state.photos[store.state.currentIndex].id
                        : nil
                },
                set: { newId in
                    if let newId,
                       let index = store.state.photos.firstIndex(where: { $0.id == newId })
                    {
                        store.send(.currentIndexChanged(index))
                    }
                }
            )) {
                ForEach(store.state.photos, id: \.id) { photo in
                    if let uiImage = photo.uiImage {
                        ZoomableImageView(
                            image: uiImage,
                            screenSize: screenSize
                        )
                        .ignoresSafeArea()
                        .tag(photo.id as UUID?)
                    }
                }
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            PhotoDetailsHeader(
                currentIndex: store.state.currentIndex + 1,
                totalCount: store.state.photos.count,
                onBackTapped: { coordinator.pop() },
                onDeleteTapped: handleDelete
            )
            .padding(.top, 6)
        }
        .navigationBarHidden(true)
        .onScreen { screen in
            if let screen {
                screenSize = screen.bounds.size
            }
        }
        .onChange(of: store.state.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                coordinator.pop()
            }
        }
    }
    
    private func handleDelete() {
        store.send(.deleteCurrentPhoto)
    }
}
