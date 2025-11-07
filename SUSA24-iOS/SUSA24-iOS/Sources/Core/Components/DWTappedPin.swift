//
//  DWTappedPin.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import SwiftUI

// MARK: - ButtonStyle Configuration

struct DWTappedPinStyle: ButtonStyle {
    var normalBg: Color = .primaryLight2
    var normalText: Color = .primaryNormal
    var normalBorder: Color
    
    var tappedBg: Color
    var tappedText: Color
    var tappedBorder: Color
    
    var padding: EdgeInsets

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.numberMedium16)
            .foregroundStyle(configuration.isPressed ? tappedText : normalText)
            .padding(padding)
            .background(configuration.isPressed ? tappedBg : normalBg)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(configuration.isPressed ? tappedBorder : normalBorder, lineWidth: 1)
            )
            .contentShape(Capsule())
            .animation(.snappy(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View

/// 탭 피드백 전용 핀(칩) 컴포넌트
///
/// ButtonStyle의 `configuration.isPressed`를 사용하여 탭 피드백을 제공합니다.
///
/// # 기본 사용
/// ```swift
/// DWTappedPin(
///     text: "확인",
///     action: { print("Tapped!") }
/// )
/// ```
///
/// # 탭 피드백 커스터마이즈
/// ```swift
/// DWTappedPin(text: "확인", action: {})
///     .tapFeedback(.gray)
/// ```
///
/// # 한 번에 설정
/// ```swift
/// DWTappedPin(text: "확인", action: {})
///     .colors(
///         normal: (bg: .white, text: .gray, border: .gray),
///         tapped: .lightGray
///     )
/// ```
struct DWTappedPin: View {
    // MARK: - Properties
    
    let text: String
    let action: () -> Void

    // 기본 상태
    var normalBg: Color = .mainBackground
    var normalText: Color = .labelNeutral
    var normalBorder: Color = .labelCoolNormal
    
    // 탭 상태
    var tappedBg: Color = .mainAlternative
    var tappedText: Color = .labelAlternative
    var tappedBorder: Color = .clear
    
    var contentPadding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)

    // MARK: - Body
    
    var body: some View {
        Button(text, action: action)
            .buttonStyle(DWTappedPinStyle(
                normalBg: normalBg,
                normalText: normalText,
                normalBorder: normalBorder,
                tappedBg: tappedBg,
                tappedText: tappedText,
                tappedBorder: tappedBorder,
                padding: contentPadding
            ))
    }
}

// MARK: - Progressive Disclosure

extension DWTappedPin {
    // MARK: - 탭 피드백
    
    /// 탭 피드백 배경색을 설정합니다.
    @discardableResult
    func tapFeedback(_ color: Color) -> Self {
        var v = self
        v.tappedBg = color
        return v
    }
    
    /// 탭 시 텍스트 색상을 설정합니다.
    @discardableResult
    func tapTextColor(_ color: Color) -> Self {
        var v = self
        v.tappedText = color
        return v
    }
    
    /// 탭 시 테두리 색상을 설정합니다.
    @discardableResult
    func tapBorder(_ color: Color) -> Self {
        var v = self
        v.tappedBorder = color
        return v
    }
    
    // MARK: - 기본 상태
    
    /// 기본 배경색을 설정합니다.
    @discardableResult
    func background(_ color: Color) -> Self {
        var v = self
        v.normalBg = color
        return v
    }
    
    /// 텍스트 색상을 설정합니다.
    @discardableResult
    func textColor(_ color: Color) -> Self {
        var v = self
        v.normalText = color
        return v
    }
    
    /// 테두리 색상을 설정합니다.
    @discardableResult
    func border(_ color: Color) -> Self {
        var v = self
        v.normalBorder = color
        return v
    }
    
    // MARK: - 한 번에 설정
    
    /// 모든 색상을 완전히 커스터마이즈합니다.
    ///
    /// - Parameters:
    ///   - normal: 기본 상태 색상 (배경, 텍스트, 테두리)
    ///   - tapped: 탭 상태 색상 (배경, 텍스트, 테두리)
    @discardableResult
    func colors(
        normal: (bg: Color, text: Color, border: Color),
        tapped: (bg: Color, text: Color, border: Color)
    ) -> Self {
        var v = self
        v.normalBg = normal.bg
        v.normalText = normal.text
        v.normalBorder = normal.border
        v.tappedBg = tapped.bg
        v.tappedText = tapped.text
        v.tappedBorder = tapped.border
        return v
    }
    
    // MARK: - 레이아웃
    
    /// 칩 내부의 패딩을 설정합니다.
    @discardableResult
    func padding(_ insets: EdgeInsets) -> Self {
        var v = self
        v.contentPadding = insets
        return v
    }
}

// MARK: - Preview

#Preview("Tapped Pin ") {
    DWTappedPin(
        text: "10:20",
        action: {
            print("삭제")
        }
    )
}
