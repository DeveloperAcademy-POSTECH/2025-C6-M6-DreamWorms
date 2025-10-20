//
//  DateRangeInput.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 날짜 범위 입력
///
/// 역할: 시작일 + 구분자 + 종료일 조합만
struct DateRangeInput: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    
    var body: some View {
        InputRow(
            startDate: $startDate,
            endDate: $endDate
        )
    }
}

// MARK: - Input Row

/// 입력 행
///
/// 역할: 필드 3개 나열만
private struct InputRow: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    
    var body: some View {
        HStack(spacing: 0) {
            DateInputField(
                placeholder: "시작일",
                date: $startDate
            )
            .padding(.horizontal, 16)
            
            DateSeparator()
            
            DateInputField(
                placeholder: "종료일",
                date: $endDate
            )
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    DateRangeInput(
        startDate: .constant(nil),
        endDate: .constant(nil)
    )
    .padding()
}
