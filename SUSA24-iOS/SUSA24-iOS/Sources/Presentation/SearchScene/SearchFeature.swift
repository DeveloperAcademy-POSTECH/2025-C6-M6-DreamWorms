//
//  SearchFeature.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/08/25.
//

import SwiftUI

/// 검색 화면의 상태와 동작을 관리하는 Redux 스타일 리듀서입니다.
struct SearchFeature: DWReducer {
    private let dispatcher: MapDispatcher
    init(dispatcher: MapDispatcher) { self.dispatcher = dispatcher }
    
    // MARK: - State
    
    struct State: DWState {
        /// 검색어 텍스트입니다.
        var searchText: String = ""
        /// 검색 결과 리스트입니다.
        var searchResults: [SearchResultItem] = []
        /// 검색 중 여부입니다.
        var isSearchLoading: Bool = false
        /// 검색 결과 선택 후 화면을 닫아야 하는지 여부입니다.
        var shouldDismiss: Bool = false
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 화면이 나타날 때 발생하는 액션입니다.
        case onAppear
        /// 검색어를 업데이트하는 액션입니다.
        /// 검색어가 변경되면 실시간으로 검색을 수행합니다.
        /// - Parameter text: 업데이트할 검색어
        case updateSearchText(String)
        /// 검색어로 장소를 검색하는 액션입니다.
        /// - Parameter query: 검색할 키워드
        case searchKeyword(String)
        /// 검색 결과를 업데이트하는 액션입니다.
        /// - Parameter results: 검색 결과 배열
        case updateSearchResults([SearchResultItem])
        /// 검색 화면을 닫는 액션입니다.
        case closeSearch
        /// 검색 결과 항목을 선택했을 때 발생하는 액션입니다.
        case selectSearchResult(SearchResultItem)
        /// 화면 닫기 신호를 소비하는 액션입니다.
        case consumeDismissSignal
    }
    
    // MARK: - Reducer
    
    /// 주어진 액션을 처리하고 다음 상태와 부수 효과를 반환합니다.
    /// 검색 요청, 결과 선택, 화면 닫기 시그널 발행 등 검색 흐름의 주요 로직이 이 함수에 정의되어 있습니다.
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            return .none
            
        case let .updateSearchText(text):
            state.searchText = text
            // 검색어가 비어있으면 결과 초기화
            if text.isEmpty {
                state.searchResults = []
                state.isSearchLoading = false
            }
            return .none
            
        case let .searchKeyword(query):
            // 검색어가 비어있으면 검색하지 않음
            guard !query.isEmpty else { return .none }
            state.isSearchLoading = true
            return .task {
                do {
                    let requestDTO = KakaoKeywordToPlaceRequestDTO(
                        query: query,
                        x: nil,
                        y: nil,
                        radius: nil,
                        page: 1,
                        size: 15
                    )

                    let response = try await KakaoSearchAPIManager.shared.fetchPlaceFromKeyword(requestDTO)
                    
                    // KakaoPlaceDocument를 SearchResultItem으로 변환
                    let results = response.documents.map { document in
                        let placeName = document.placeName ?? document.roadAddressName ?? document.addressName ?? ""
                        let roadAddress = document.roadAddressName ?? ""
                        let jibunAddress = document.addressName ?? ""
                        let phoneNumber = document.phone ?? ""
                        let latitude = Double(document.y ?? "")
                        let longitude = Double(document.x ?? "")
                        let identifier = document.id ?? UUID().uuidString
                        
                        return SearchResultItem(
                            id: identifier,
                            title: placeName,
                            jibunAddress: jibunAddress,
                            roadAddress: roadAddress,
                            phoneNumber: phoneNumber,
                            latitude: latitude,
                            longitude: longitude
                        )
                    }
                    return .updateSearchResults(results)
                } catch {
                    return .updateSearchResults([])
                }
            }
            
        case let .updateSearchResults(results):
            state.searchResults = results
            state.isSearchLoading = false
            return .none
            
        case .closeSearch:
            // 코디네이터에서 처리하므로 여기서는 상태만 초기화
            state.searchText = ""
            state.searchResults = []
            state.isSearchLoading = false
            state.shouldDismiss = false
            return .none
            
        case let .selectSearchResult(item):
            guard let latitude = item.latitude, let longitude = item.longitude
            else { return .none }
            let coordinate = MapCoordinate(latitude: latitude, longitude: longitude)
            let placeInfo = PlaceInfo(
                title: item.title,
                jibunAddress: item.jibunAddress,
                roadAddress: item.roadAddress,
                phoneNumber: item.phoneNumber
            )
            dispatcher.send(.moveToSearchResult(coordinate: coordinate, placeInfo: placeInfo))
            state.shouldDismiss = true
            return .none
            
        case .consumeDismissSignal:
            state.shouldDismiss = false
            return .none
        }
    }
}
