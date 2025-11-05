//
//  DWGlassEffectCircleButton.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// glassEffect 모디파이어를 사용하는 아이콘 버튼 컴포넌트입니다.
///
/// `DWCircleButton`은 `buttonStyle(.glass)`를 사용하지만, 이 컴포넌트는 레이아웃 제어를 위해
/// `glassEffect()` 모디파이어를 직접 사용합니다. 헤더의 백 버튼, 스캔 버튼 등에 사용됩니다.
struct DWGlassEffectCircleButton: View {
    /// 버튼을 탭했을 때 실행되는 액션입니다.
    let action: () -> Void
    
    /// 아이콘 이미지입니다.
    let icon: Image
    /// 버튼의 크기입니다 (width, height 동일).
    var size: CGFloat = 44
    /// 아이콘의 크기입니다.
    var iconSize: CGFloat = 18
    /// 아이콘의 너비입니다. 지정하지 않으면 iconSize를 사용합니다.
    var iconWidth: CGFloat?
    /// 아이콘의 높이입니다. 지정하지 않으면 iconSize를 사용합니다.
    var iconHeight: CGFloat?
    /// 아이콘 색상입니다.
    var iconColor: Color = .labelNeutral
    /// 인터랙션(떠오르는) 효과 사용 여부입니다.
    var isInteractiveEffect: Bool = true
    /// 버튼 배경 색상입니다.
    var buttonBackgroundColor: Color = .clear
    
    var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .foregroundStyle(iconColor)
                .frame(
                    width: iconWidth ?? iconSize,
                    height: iconHeight ?? iconSize
                )
                .frame(width: size, height: size)
        }
        .background(
            Circle()
                .foregroundColor(buttonBackgroundColor)
        )
        .glassEffect(isInteractiveEffect ? .regular.interactive() : .regular.tint(.primaryLight1))
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension DWGlassEffectCircleButton {
    
    /// 버튼의 크기를 설정합니다.
    /// - Parameter size: 버튼의 width, height 값
    @discardableResult
    func setupSize(_ size: CGFloat) -> Self {
        var view = self
        view.size = size
        return view
    }
    
    /// 아이콘의 크기를 설정합니다.
    /// - Parameter size: 아이콘의 width, height 값
    @discardableResult
    func setupIconSize(_ size: CGFloat) -> Self {
        var view = self
        view.iconSize = size
        return view
    }
    
    /// 아이콘의 너비와 높이를 설정합니다.
    /// - Parameters:
    ///   - width: 아이콘의 너비
    ///   - height: 아이콘의 높이
    @discardableResult
    func setupIconSize(width: CGFloat, height: CGFloat) -> Self {
        var view = self
        view.iconWidth = width
        view.iconHeight = height
        return view
    }
    
    /// 아이콘 색상을 설정합니다.
    /// - Parameter color: 아이콘 색상
    @discardableResult
    func setupIconColor(_ color: Color) -> Self {
        var view = self
        view.iconColor = color
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
    
    /// 버튼 컬러를 설정합니다.
    /// - Parameter color: 배경 색상
    @discardableResult
    func setupbuttonBackgroundColor(_ color: Color) -> Self {
        var view = self
        view.buttonBackgroundColor = color
        return view
    }
}

//#Preview {
//    HStack(spacing: 16) {
//        DWGlassEffectCircleButton(
//            action: {},
//            icon: Image(.back)
//        )
//        .setupSize(44)
//        .setupIconSize(18)
//        
//        DWGlassEffectCircleButton(
//            action: {},
//            icon: Image(.scan)
//        )
//        .setupSize(48)
//        .setupIconSize(width: 25, height: 19)
//    }
//    .padding()
//}

