//
//  PinWriteHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/13/25.
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
            .setupbuttonBackgroundColor(.white)
            .setupSize(36)
            .setupIconSize(14)
            
            Spacer()
            
            Text(title)
                .font(.titleSemiBold16)
                .foregroundStyle(.labelNormal)
            
            Spacer()
            
            DWGlassEffectCircleButton(
                image: Image(.checkmark),
                action: onSaveTapped
            )
            .setupSize(36)
            .setupIconSize(14)
            .setupIconColor(.white)
            .setupbuttonBackgroundColor(isSaveEnabled ? .primaryNormal : .gray99)
            .disabled(!isSaveEnabled)
        }
        .padding(.top, 10)
        .padding(.bottom, 14)
    }
}
//
//#Preview {
//    PinWriteHeader(
//        title: "핀 추가",
//        isSaveEnabled: false,
//        onCloseTapped: {},
//        onSaveTapped: {}
//    )
//}
