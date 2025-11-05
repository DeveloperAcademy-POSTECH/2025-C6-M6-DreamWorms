//
//  TimeLineDateSectionHeader.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//
import SwiftUI

// MARK: - View

/// 타임라인 날짜 섹션 헤더 컴포넌트
///
/// LazyVStack의 Section 헤더로 사용됩니다.
/// - 날짜 텍스트 표시 (예: "10월 30일 (목)")
/// - 배경색: .mainBackground (스크롤 시 고정)
///
/// # 사용예시
/// ```swift
/// Section {
///     // 리스트 내용
/// } header: {
///     TimeLineDateSectionHeader(text: "10월 30일 (목)")
/// }
/// ```
struct TimeLineDateSectionHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.bodyMedium16)
            .foregroundStyle(.labelNormal)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("날짜 섹션 헤더") {
    VStack(spacing: 0) {
        TimeLineDateSectionHeader(text: "11월 5일 (화)")
        TimeLineDateSectionHeader(text: "11월 4일 (월)")
        TimeLineDateSectionHeader(text: "11월 3일 (일)")
    }
}
