//
//  DateGroupHeader.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import SwiftUI

/// 날짜 그룹 헤더
///
/// 역할: 날짜 표시만
struct DateGroupHeader: View {
    let date: Date
    
    var body: some View {
        HeaderContainer(date: date)
    }
}

// MARK: - Header Container

/// 헤더 컨테이너
///
/// 역할: 레이아웃만
private struct HeaderContainer: View {
    let date: Date
    
    var body: some View {
        HStack {
            DateText(date: date)
            Spacer()
        }
    }
}

// MARK: - Date Text

/// 날짜 텍스트
///
/// 역할: 날짜 포맷팅 + 스타일만
private struct DateText: View {
    let date: Date
    
    var body: some View {
        Text(formattedDate)
            .font(.pretendardBold(size: 16))
            .foregroundStyle(Color.black22)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        DateGroupHeader(date: Date())
        DateGroupHeader(date: Date().addingTimeInterval(-86400))
    }
    .padding()
}
