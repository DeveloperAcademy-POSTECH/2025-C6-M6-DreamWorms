//
//  DateSeparator.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 날짜 구분자
///
/// 역할: "-" 표시만
struct DateSeparator: View {
    var body: some View {
        SeparatorText()
    }
}

// MARK: - Separator Text

/// 구분자 텍스트
///
/// 역할: 텍스트 스타일만
private struct SeparatorText: View {
    var body: some View {
        Text(.caseBottomSheetSeparator)
            .font(.pretendardSemiBold(size: 14))
            .foregroundStyle(Color.grayE5)
    }
}

// MARK: - Preview

#Preview {
    HStack {
        Text("시작일")
        DateSeparator()
        Text("종료일")
    }
    .padding()
}
