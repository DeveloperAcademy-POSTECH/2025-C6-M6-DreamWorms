//
//  DWButton.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

/// 왕꿈틀이가 사용하는 기본 버튼 컴포넌트
///
/// `DWButton`은 다음 요구사항을 충족하도록 설계되었습니다:
///
/// - 외부 상태 바인딩(`@Binding isEnabled`)으로 활성/비활성 제어
/// - 일관된 타이포/레이아웃 토큰(패딩, 높이 등)
/// - 아이콘, 전경/배경 색상, 인터랙션 효과를 간단히 체이닝으로 커스터마이즈
/// - Progressive Disclosure 원칙을 적용(조건 충족 전 비활성 → 충족 시 활성)
struct DWButton: View {
    @Binding var isEnabled: Bool

    let title: String = "추가"
    let action: () -> Void
    
    var iconImage: Image? = nil
    var foregroundColor: Color = .white
    var backgroundColor: Color = .primaryNormal
    var verticalPadding: CGFloat = 16
    var isInteractiveEffect: Bool = true
    var isHapticFeedback: Bool = true
        
    // MARK: - View

    var body: some View {
        Button {
            if isHapticFeedback { triggerMediumHapticFeedback() }
            action()
        } label: {
            HStack(spacing: 6) {
                if let iconImage {
                    iconImage
                        .renderingMode(.template)
                        .foregroundColor(foregroundColor)
                }
                
                Text(title)
                    .font(.titleSemiBold16)
            }
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
        }
        .disabled(!isEnabled)
        .glassEffect(.regular.tint(backgroundColor))
        .glassEffect(isInteractiveEffect ? .regular.interactive() : .regular)
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension DWButton {
    
    /// 아이콘을 설정합니다.
    /// - Parameter image: 선행 아이콘 이미지. `nil`이면 아이콘을 숨깁니다.
    @discardableResult
    func setupImage(_ image: Image) -> Self {
        var view = self
        view.iconImage = image
        return view
    }
    
    /// 배경색을 설정합니다.
    /// - Parameter color: 배경색
    @discardableResult
    func setupBackgroundColor(_ color: Color) -> Self {
        var view = self
        view.backgroundColor = color
        return view
    }
    
    /// 전경색(텍스트/아이콘 색)을 설정합니다.
    /// - Parameter color: 전경색
    @discardableResult
    func setupForegroundColor(_ color: Color) -> Self {
        var view = self
        view.foregroundColor = color
        return view
    }
    
    /// 세로 (위아래) 패딩을 설정합니다.
    /// - Parameter padding: 상하 패딩 값
    @discardableResult
    func setupVerticalPadding(_ padding: CGFloat) -> Self {
        var view = self
        view.verticalPadding = padding
        return view
    }
    
    /// 인터랙션(떠오르는) 효과 사용 여부를 설정합니다.
    /// - Parameter isOn: `true`면 리퀴드 글래스 인터랙션 효과 활성화
    @discardableResult
    func setupInteractiveEffect(_ isInteractive: Bool) -> Self {
        var view = self
        view.isInteractiveEffect = isInteractive
        return view
    }
    
    /// 버튼을 눌렀을 때 햅틱 피드백을 제공할 것인지 여부를 설정합니다.
    /// - Parameter isHaptic: `true`면 버튼을 눌렀을 때 햅틱 발생
    @discardableResult
    func setupHapticFeedback(_ isHaptic: Bool) -> Self {
        var view = self
        view.isHapticFeedback = isHaptic
        return view
    }
}
