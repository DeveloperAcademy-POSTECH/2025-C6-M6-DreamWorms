//
//  DateInputField.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 날짜 입력 필드
///
/// 역할: 텍스트 필드 UI만
struct DateInputField: View {
    let placeholder: String
    @Binding var date: Date?
    
    var body: some View {
        FieldContainer(
            placeholder: placeholder,
            date: $date
        )
    }
}

// MARK: - Field Container

/// 필드 컨테이너
///
/// 역할: 배경 + 텍스트만
private struct FieldContainer: View {
    let placeholder: String
    @Binding var date: Date?
    
    var body: some View {
        ZStack {
            FieldBackground()
            FieldText(placeholder: placeholder, date: date)
        }
        .frame(height: 40)
    }
}

// MARK: - Field Background

/// 필드 배경
///
/// 역할: 배경색 + 모서리만
private struct FieldBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.grayE5, lineWidth: 1)
            )
    }
}

// MARK: - Field Text

/// 필드 텍스트
///
/// 역할: 텍스트 표시만
private struct FieldText: View {
    let placeholder: String
    let date: Date?
    
    var body: some View {
        Text(displayText)
            .font(.pretendardRegular(size: 14))
            .foregroundStyle(textColor)
    }
    
    private var displayText: String {
        if let date {
            formatDate(date)
        } else {
            placeholder
        }
    }
    
    private var textColor: Color {
        date == nil ? Color.grayCA : Color.black22
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Empty") {
    VStack {
        DateInputField(placeholder: "시작일", date: .constant(nil))
        DateInputField(placeholder: "종료일", date: .constant(nil))
    }
    .padding()
}

#Preview("Filled") {
    VStack {
        DateInputField(placeholder: "시작일", date: .constant(Date()))
        DateInputField(placeholder: "종료일", date: .constant(Date().addingTimeInterval(86400 * 7)))
    }
    .padding()
}
