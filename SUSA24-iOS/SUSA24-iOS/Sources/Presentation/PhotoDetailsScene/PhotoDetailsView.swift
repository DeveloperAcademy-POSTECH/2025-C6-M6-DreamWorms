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
    
    @State private var zoomStates: [UUID: ZoomState] = [:]
    
    init(store: DWStore<PhotoDetailsFeature>) {
        _store = State(initialValue: store)
        
        // 각 사진마다 ZoomState 초기화 시킨다.
        var states: [UUID: ZoomState] = [:]
        for photo in store.state.photos {
            states[photo.id] = ZoomState()
        }
        _zoomStates = State(initialValue: states)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
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
                    PhotoImageView(photo: photo, zoomState: zoomStateBinding(for: photo.id))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(photo.id as UUID?)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            PhotoDetailsHeader(
                currentIndex: store.state.currentIndex + 1,
                totalCount: store.state.photos.count,
                onBackTapped: { coordinator.pop() },
                onDeleteTapped: handleDelete
            )
            .padding(.top, 6)
            .padding(.bottom, 54)
        }
        .navigationBarHidden(true)
        .onChange(of: store.state.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                coordinator.pop()
            }
        }
    }
    
    private var currentIndexBinding: Binding<Int> {
        Binding(
            get: { store.state.currentIndex },
            set: { newIndex in
                store.send(.currentIndexChanged(newIndex))
            }
        )
    }
    
    private func zoomStateBinding(for photoID: UUID) -> Binding<ZoomState> {
        Binding(
            get: { zoomStates[photoID] ?? ZoomState() },
            set: { zoomStates[photoID] = $0 }
        )
    }
    
    private func handleDelete() {
        if let currentPhoto = store.state.currentPhoto {
            zoomStates.removeValue(forKey: currentPhoto.id)
        }
        store.send(.deleteCurrentPhoto)
    }
}
