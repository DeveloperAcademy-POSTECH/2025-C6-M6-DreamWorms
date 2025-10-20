//
//  SearchViewModel.swift
//  DreamWorms-iOS
//
//  Created by Assistant on 2025-01-27.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [LocalSearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchTextObserver()
    }
    
    private func setupSearchTextObserver() {
        $searchText
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main) // 디바운스 시간 증가
            .removeDuplicates()
            .sink { [weak self] searchText in
                Task { @MainActor in
                    await self?.performSearch(query: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await LocalSearchService.search(query: query)
            
            await MainActor.run {
                searchResults = results
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                searchResults = []
                isLoading = false
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        errorMessage = nil
    }
    
    func selectSearchResult(_ result: LocalSearchResult) {
        // 검색 결과 선택 시 지도로 이동 + 바텀시트 표시 알림 전송
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowSearchResult"),
            object: result
        )
    }
}
