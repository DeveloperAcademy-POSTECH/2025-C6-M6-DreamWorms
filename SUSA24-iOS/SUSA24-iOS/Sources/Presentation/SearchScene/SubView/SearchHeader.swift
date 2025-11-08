//
//  SearchHeader.swift
//  SUSA24-iOS
//
//  Created by Assistant on 11/8/25.
//

import SwiftUI

/// 검색 헤더 컴포넌트
struct SearchHeader: View {
    @Binding var searchText: String
    @FocusState.Binding var isSearchFieldFocused: SearchField?
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            DWTextField(
                text: $searchText,
                field: SearchField.search,
                externalFocus: $isSearchFieldFocused,
                placeholder: "장소명, 도로명주소, 지번주소"
            )
            .setupPadding(EdgeInsets(top: 13.5, leading: 16, bottom: 13.5, trailing: 24))
            .setupHeight(46)
            .setupBackgroundColor(.clear)
            .glassEffect()
            
            DWGlassEffectCircleButton(
                image: Image(.xmark),
                action: onClose
            )
            .setupSize(44)
            .setupIconSize(14)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }
}

// MARK: - Search Field

enum SearchField: Hashable {
    case search
}
