//
//  NoteWriteHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/21/25.
//

import SwiftUI

/// 형사 노트 작성/수정 화면의 상단 헤더 컴포넌트
struct NoteWriteHeader: View {
    let isSaveEnabled: Bool
    let onCloseTapped: () -> Void
    let onSaveTapped: () -> Void
    
    var body: some View {
        HStack {
            DWGlassEffectCircleButton(
                image: Image(.xmark),
                action: onCloseTapped
            )
            .setupSize(36)
            .setupIconSize(14)
            
            Spacer()
            
            Text(String(localized: .memoWriteTitle))
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
            .setupbuttonBackgroundColor(isSaveEnabled ? .primaryNormal : .labelAssistive)
            .disabled(!isSaveEnabled)
        }
        .padding(.horizontal, 16)
    }
}
