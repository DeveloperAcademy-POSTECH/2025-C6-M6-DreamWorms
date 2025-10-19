//
//  DWMapSearchBar.swift
//  DreamWorms-iOS
//
//  Created by Muchan Kim on 10/19/25.
//

import SwiftUI

struct DWMapSearchBar: View {
    private let placeholder: String
    private let onTap: () -> Void
    
    @State private var isPressed = false
    
    init(
        placeholder: String = String(localized: "장소, 주소 검색"),
        onTap: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 8) {
                Text(placeholder)
                    .font(.pretendardRegular(size: 16))
                    .foregroundStyle(Color.gray8B)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(.icnSearch24)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray44)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: 48)
        .buttonStyle(PlainButtonStyle())
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 2)
        .onLongPressGesture(minimumDuration: 0) {} onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DWMapSearchBar(
            onTap: { print("검색") }
        )
        
        DWMapSearchBar(
            placeholder: "다른 검색어",
            onTap: { print("검색") }
        )
    }
    .padding()
    .background(Color.grayF2)
}
