//
//  SearchView.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store: DWStore<SearchFeature>
    
    // MARK: - Properties
    
    @FocusState private var isSearchFieldFocused: SearchField?
    @State private var searchTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(store: DWStore<SearchFeature>) { _store = State(initialValue: store) }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            SearchHeader(
                searchText: Binding(
                    get: { store.state.searchText },
                    set: { store.send(.updateSearchText($0)) }
                ),
                isSearchFieldFocused: $isSearchFieldFocused,
                onClose: {
                    store.send(.closeSearch)
                    coordinator.pop()
                }
            )
            
            if store.state.isSearchLoading {
                CircleProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !store.state.searchResults.isEmpty {
                ScrollView {
                    SearchResultsList(
                        items: store.state.searchResults,
                        onItemSelected: { item in
                            store.send(.selectSearchResult(item))
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Spacer()
            }
        }
        .background(.mainAlternative)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task { @MainActor in
                store.send(.onAppear)
                try? await Task.sleep(for: seconds(0.1))
                isSearchFieldFocused = .search
            }
        }
        .onChange(of: store.state.searchText) { _, newValue in
            searchTask?.cancel()
            guard !newValue.isEmpty else { return }
            searchTask = Task {
                try? await Task.sleep(for: seconds(0.3))
                guard !Task.isCancelled, store.state.searchText == newValue else { return }
                store.send(.searchKeyword(newValue))
            }
        }
        .onChange(of: store.state.shouldDismiss) { _, newValue in
            guard newValue else { return }
            store.send(.consumeDismissSignal)
            coordinator.pop()
        }
    }
}

// MARK: - Preview

// #Preview("SearchView") {
//    let store = DWStore(
//        initialState: SearchFeature.State(
//            searchText: "장난감",
//            searchResults: [
//                SearchResultItem(
//                    id: "1",
//                    title: "토이저러스 대구율하점",
//                    jibunAddress: "대구 동구 율하동 1117",
//                    roadAddress: "대구 동구 안심로 80",
//                    phoneNumber: "02-1234-5678",
//                    latitude: 35.8714,
//                    longitude: 128.6014
//                ),
//                SearchResultItem(
//                    id: "2",
//                    title: "토이저러스 롯데마트김포공항점",
//                    jibunAddress: "서울 강서구 방화동 886",
//                    roadAddress: "서울 강서구 방화동 886",
//                    phoneNumber: "02-9876-5432",
//                    latitude: 37.5581,
//                    longitude: 126.7957
//                ),
//            ]
//        ),
//        reducer: SearchFeature(dispatcher: MapDispatcher())
//    )
//    return SearchView(store: store)
//        .environment(AppCoordinator())
// }
