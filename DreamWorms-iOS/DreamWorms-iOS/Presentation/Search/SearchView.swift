//
//  SearchView.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI

enum SearchState {
    case loading
    case error(String)
    case emptyResults
    case empty
    case results([LocalSearchResult])
}

struct SearchView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = SearchViewModel()
    
    private var searchState: SearchState {
        if viewModel.isLoading {
            return .loading
        }
        
        if let errorMessage = viewModel.errorMessage {
            return .error(errorMessage)
        }
        
        let hasResults = !viewModel.searchResults.isEmpty
        let hasSearchText = !viewModel.searchText.isEmpty
        
        switch (hasResults, hasSearchText) {
        case (false, false):
            return .empty
        case (false, true):
            return .emptyResults
        case (true, _):
            return .results(viewModel.searchResults)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchHeader(
                text: $viewModel.searchText,
                onBack: {
                    coordinator.pop()
                },
                onSubmit: {
                    Task {
                        await viewModel.performSearch(query: viewModel.searchText)
                    }
                },
                onClear: {
                    viewModel.clearSearch()
                }
            )
            
            Divider()
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            
            SearchContentView(
                state: searchState,
                onResultTap: { result in
                    viewModel.selectSearchResult(result)
                    coordinator.pop()
                }
            )
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - SearchContentView

struct SearchContentView: View {
    let state: SearchState
    let onResultTap: (LocalSearchResult) -> Void
    
    var body: some View {
        switch state {
        case .loading:
            SearchLoadingView()
        case let .error(message):
            SearchErrorView(errorMessage: message)
        case .emptyResults:
            SearchEmptyView()
        case .empty:
            SearchPlaceholderView()
        case let .results(results):
            SearchResultView(searchResults: results, onResultTap: onResultTap)
        }
    }
}

// MARK: - SubViews

struct SearchLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView("검색 중...")
                .font(.pretendardRegular(size: 14))
                .foregroundStyle(Color.gray8B)
            Spacer()
        }
    }
}

struct SearchErrorView: View {
    let errorMessage: String
    
    var body: some View {
        VStack {
            Spacer()
            Text("검색 중 오류가 발생했습니다")
                .font(.pretendardRegular(size: 16))
                .foregroundStyle(Color.gray8B)
            Text(errorMessage)
                .font(.pretendardRegular(size: 14))
                .foregroundStyle(Color.gray8B)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Spacer()
        }
    }
}

struct SearchEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("검색 결과가 없습니다")
                .font(.pretendardRegular(size: 16))
                .foregroundStyle(Color.gray8B)
            Spacer()
        }
    }
}

struct SearchPlaceholderView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("장소를 검색해보세요")
                .font(.pretendardRegular(size: 16))
                .foregroundStyle(Color.gray8B)
            Spacer()
        }
    }
}

struct SearchResultView: View {
    let searchResults: [LocalSearchResult]
    let onResultTap: (LocalSearchResult) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(searchResults.enumerated()), id: \.offset) { index, result in
                    SearchResultRow(
                        placeName: result.title,
                        address: result.roadAddress.isEmpty ? result.address : result.roadAddress,
                        category: result.category,
                        distance: "거리 정보 없음",
                        reviewCount: 0,
                        onTap: {
                            onResultTap(result)
                        }
                    )
                    
                    if index < searchResults.count - 1 {
                        Divider()
                            .padding(.horizontal, 12)
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(AppCoordinator())
}
