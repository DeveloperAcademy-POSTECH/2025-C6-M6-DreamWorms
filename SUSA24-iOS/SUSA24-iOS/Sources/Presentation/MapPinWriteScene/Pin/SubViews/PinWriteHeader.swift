//
//  PinWriteHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/13/25.
//

//
//  PinWriteHeader.swift
//  SUSA24-iOS
//
//  Created by AI Assistant on 11/13/25.
//

import SwiftUI

/// 핀 추가/수정 화면의 상단 헤더 컴포넌트
struct PinWriteHeader: View {
    let title: String
    let isSaveEnabled: Bool
    let onCloseTapped: () -> Void
    let onSaveTapped: () -> Void
    
    var body: some View {
        HStack {
            DWGlassEffectCircleButton(
                image: Image(.xmark),
                action: onCloseTapped
            )
            
            Spacer()
            
            Text(title)
                .font(.titleSemiBold20)
                .foregroundStyle(.labelNormal)
            
            Spacer()
            
            DWGlassEffectCircleButton(
                image: Image(.checkmark),
                action: onSaveTapped
            )
            .disabled(!isSaveEnabled)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}

// #Preview {
//    PinWriteHeader(
//        title: "핀 추가",
//        isSaveEnabled: true,
//        onCloseTapped: {},
//        onSaveTapped: {}
//    )
// }
