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
    
    var textFont: Font = .bodyMedium14
    var textColor: Color = .labelAlternative
    var textAlignment: TextAlignment = .center
    var contentPadding: EdgeInsets = .init(top: 30, leading: 16, bottom: 30, trailing: 16)
    var backgroundColor: Color = .clear
    var cornerRadius: CGFloat = 0
    
    var body: some View {
        Text(message)
            .font(textFont)
            .foregroundStyle(textColor)
            .multilineTextAlignment(textAlignment)
            .frame(maxWidth: .infinity)
            .padding(contentPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Progressive Disclosure

extension TimeLineEmptyState {
    
    // MARK: - 텍스트 스타일
    
    /// 폰트를 설정합니다.
    ///
    /// - Parameter font: 적용할 폰트
    @discardableResult
    func setupFont(_ font: Font) -> Self {
        var v = self
        v.textFont = font
        return v
    }
    
    /// 텍스트 색상을 설정합니다.
    ///
    /// - Parameter color: 적용할 색상
    @discardableResult
    func setupTextColor(_ color: Color) -> Self {
        var v = self
        v.textColor = color
        return v
    }
    
    /// 텍스트 정렬을 설정합니다.
    ///
    /// - Parameter alignment: 정렬 방식 (.leading, .center, .trailing)
    @discardableResult
    func setupTextAlignment(_ alignment: TextAlignment) -> Self {
        var v = self
        v.textAlignment = alignment
        return v
    }
    
    @discardableResult
    func setupBackground(_ color: Color) -> Self {
        var v = self
        v.backgroundColor = color
        return v
    }
    
    /// 모서리 둥글기를 설정합니다.
    ///
    /// - Parameter radius: 적용할 corner radius 값
    @discardableResult
    func setupRadius(_ radius: CGFloat) -> Self {
        var v = self
        v.cornerRadius = radius
        return v
    }
    
    // MARK: - 레이아웃
    
    /// 패딩을 설정합니다.
    ///
    /// - Parameter insets: 적용할 패딩
    @discardableResult
    func setupPadding(_ insets: EdgeInsets) -> Self {
        var v = self
        v.contentPadding = insets
        return v
    }
}

//#Preview("Empty State - Default") {
//    TimeLineEmptyState(
//        message: "아직 확인된 기지국 정보가 없어요."
//    )
//    .setupBackground(.black)
//    .setupRadius(15)
//}
//
//#Preview("Empty State - With Radius") {
//    TimeLineEmptyState(
//        message: "데이터가 없습니다"
//    )
//    .setupBackground(.mainAlternative)
//    .setupRadius(12)
//}
