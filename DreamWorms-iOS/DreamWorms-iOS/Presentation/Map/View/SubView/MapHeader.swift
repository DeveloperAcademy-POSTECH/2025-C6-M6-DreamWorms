//
//  MapHeader.swift
//  DreamWorms-iOS
//
//  Created by Muchan Kim on 10/19/25.
//

import SwiftUI

struct MapHeader: View {
    private let placeholder: String
    private let onBack: () -> Void
    private let onSearch: () -> Void
    
    init(
        placeholder: String = String(localized: "장소, 주소 검색"),
        onBack: @escaping () -> Void,
        onSearch: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self.onBack = onBack
        self.onSearch = onSearch
    }
    
    var body: some View {
        HStack(spacing: 8) {
            DWCircleButton(systemImage: "chevron.left") {
                onBack()
            }
            
            DWMapSearchBar(
                placeholder: placeholder,
                onTap: onSearch
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        MapHeader(
            onBack: { print("뒤로") },
            onSearch: { print("검색") }
        )
        
        MapHeader(
            placeholder: "다른 검색어",
            onBack: { print("뒤로") },
            onSearch: { print("검색") }
        )
    }
    .background(Color.white)
}
