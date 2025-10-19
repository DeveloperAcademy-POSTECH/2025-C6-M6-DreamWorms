//
//  SearchHeader.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/19/25.
//

import SwiftUI

struct SearchHeader: View {
    private let placeholder: String
    private let onBack: () -> Void
    private let onSubmit: (() -> Void)?
    private let onClear: (() -> Void)?
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    init(
        text: Binding<String>,
        placeholder: String = "장소, 주소 검색",
        onBack: @escaping () -> Void,
        onSubmit: (() -> Void)? = nil,
        onClear: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onBack = onBack
        self.onSubmit = onSubmit
        self.onClear = onClear
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 뒤로가기 버튼 (배경 없음)
            Button(action: {
                triggerLightHapticFeedback()
                onBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.black22)
                    .frame(width: 32, height: 32)
            }
            
            // 검색 필드
            SearchField(
                text: $text,
                placeholder: placeholder,
                onSubmit: onSubmit,
                onClear: onClear
            )
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - SearchField 서브뷰

struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: (() -> Void)?
    let onClear: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .font(.pretendardRegular(size: 16))
                .foregroundStyle(Color.black22)
                .submitLabel(.search)
                .onSubmit {
                    onSubmit?()
                }
            
            Button {
                if text.isEmpty {
                    triggerMediumHapticFeedback()
                    onSubmit?()
                } else {
                    triggerLightHapticFeedback()
                    text = ""
                    onClear?()
                }
            } label: {
                text.isEmpty ?
                    Image(.icnSearch24)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray44)
                    .frame(width: 32, height: 32) :
                    Image(.icnClose24)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray8B)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, maxHeight: 56)
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchHeader(
            text: .constant(""),
            onBack: { print("뒤로") }
        )
        
        SearchHeader(
            text: .constant("편의점"),
            onBack: { print("뒤로") }
        )
    }
    .background(Color.grayF2)
}
