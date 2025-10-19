//
//  SearchView.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            SearchHeader(
                text: $searchText,
                onBack: {
                    coordinator.pop()
                },
                onSubmit: {
                    // NOTE: 검색 API 호출 들어 갈 자리
                },
                onClear: {
                    searchText = ""
                }
            )
            
            Divider()
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(MockSearchData.results.enumerated()), id: \.offset) { index, result in
                        SearchResultRow(
                            placeName: result.placeName,
                            address: result.address,
                            category: result.category,
                            distance: result.distance,
                            reviewCount: result.reviewCount,
                            onTap: {
                                // NOTE: 누르면 그 위치로 이동하게 해야 함.
                                print("선택됨: \(result.placeName)")
                            }
                        )
                        
                        if index < MockSearchData.results.count - 1 {
                            Divider()
                                .padding(.horizontal, 12)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

// 임시 목데이터
struct SearchResultData {
    let placeName: String
    let address: String
    let category: String
    let distance: String
    let reviewCount: Int
}

enum MockSearchData {
    static let results = [
        SearchResultData(
            placeName: "GS25 포항효성로점",
            address: "경북 포항시 남구 효성로 54 (효자동 597)",
            category: "편의점",
            distance: "1.5km",
            reviewCount: 497
        ),
        SearchResultData(
            placeName: "CU 포항효자센터점",
            address: "경북 포항시 남구 효자동 123-45",
            category: "편의점",
            distance: "1.8km",
            reviewCount: 234
        ),
        SearchResultData(
            placeName: "세븐일레븐 포항남부점",
            address: "경북 포항시 남구 남부동 67-89",
            category: "편의점",
            distance: "2.1km",
            reviewCount: 156
        ),
        SearchResultData(
            placeName: "스타벅스 포항점",
            address: "경북 포항시 남구 중앙로 123",
            category: "카페",
            distance: "0.8km",
            reviewCount: 892
        ),
        SearchResultData(
            placeName: "맥도날드 포항점",
            address: "경북 포항시 남구 대잠동 456-78",
            category: "패스트푸드",
            distance: "2.5km",
            reviewCount: 445
        ),
    ]
}

#Preview {
    SearchView()
        .environmentObject(AppCoordinator())
}
