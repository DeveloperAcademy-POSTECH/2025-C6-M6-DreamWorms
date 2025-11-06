//
//  TimeLineSearchBar.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/7/25.
//

import SwiftUI

struct TimeLineSearchBar: View {
    
    // MARK: - Dependencies
    
    let store: DWStore<TimeLineFeature>
    @FocusState.Binding var isSearchFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            DWSheetSearchBar(
                text: Binding(
                    get: { store.state.searchText },
                    set: { store.send(.searchTextChanged($0)) }
                ),
                isFocused: $isSearchFocused
            )
            .setupPlaceholder(.bottomSheetCellLocationSearchText)
            
            // 포커스와 텍스트 있을때만 X 버튼
            if isSearchFocused && !store.state.searchText.isEmpty {
                Button {
                    triggerLightHapticFeedback()
                    isSearchFocused = false
                    store.send(.searchTextChanged(""))
                } label : {
                    Image(.xmark)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.labelNeutral)
                        .frame(width: 44, height: 44)
                        .background(.mainAlternative)
                        .clipShape(Circle())
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .animation(.snappy, value: isSearchFocused)
        .animation(.snappy, value: store.state.searchText)

        
    }
}
//
//#Preview("Search Bar States") {
//    TimeLineSearchBarPreview()
//}
//
//private struct TimeLineSearchBarPreview: View {
//    @State private var store = DWStore(
//        initialState: TimeLineFeature.State(
//            caseInfo: nil,
//            locations: []
//        ),
//        reducer: TimeLineFeature()
//    )
//    
//    @FocusState private var isSearchFocused: Bool
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // 상태 표시
//            Text("Focus: \(isSearchFocused ? "활성" : "비활성")")
//                .font(.caption)
//                .foregroundStyle(.labelAssistive)
//            
//            Text("Text: '\(store.state.searchText)'")
//                .font(.caption)
//                .foregroundStyle(.labelAssistive)
//            
//            Divider()
//            
//            // 실제 SearchBar
//            TimeLineSearchBar(
//                store: store,
//                isSearchFocused: $isSearchFocused
//            )
//            
//            Spacer()
//            
//            // 테스트 버튼들
//            VStack(spacing: 12) {
//                Button("포커스 토글") {
//                    isSearchFocused.toggle()
//                }
//                
//                Button("텍스트 추가") {
//                    store.send(.searchTextChanged(store.state.searchText + "테스트 "))
//                }
//                
//                Button("텍스트 초기화") {
//                    store.send(.searchTextChanged(""))
//                }
//            }
//            .buttonStyle(.bordered)
//        }
//        .padding()
//        .background(.mainBackground)
//    }
//}
