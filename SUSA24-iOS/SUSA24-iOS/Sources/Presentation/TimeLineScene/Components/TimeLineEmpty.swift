//
//  TimeLineEmptyState.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import SwiftUI

// MARK: - View

/// 타임라인 데이터가 없을 때 표시되는 Empty State 컴포넌트
///
/// 바텀시트에서 데이터가 없을 때 사용됩니다.
///
/// # 사용예시
/// ```swift
/// TimeLineEmptyState(
///     message: "아직 확인된 기지국 정보가 없어요."
/// )
/// ```
struct TimeLineEmptyState: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.bodyMedium14)
            .foregroundStyle(.labelAlternative)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(
                .init(top: 30, leading: 16, bottom: 30, trailing: 16)
            )
    }
}

//// MARK: - Preview
//
//#Preview("Empty State - Single Line") {
//    TimeLineEmptyState(
//        message: "아직 확인된 기지국 정보가 없어요."
//    )
//    .background(.black)
//}
//
//#Preview("Empty State - Multi Line") {
//    TimeLineEmptyState(
//        message: "아직 확인된 기지국 정보가 없어요.\n나중에 다시 확인해주세요."
//    )
//    .background(.mainBackground)
//}
