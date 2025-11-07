//
//  DWCircleButton.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct DWCircleButton: View {
    let image: Image
    let action: () -> Void
    
    var size: CGFloat = 44
    var iconInset: CGFloat = 8
    var foregroundColor: Color = .labelNeutral

    var body: some View {
        Button(action: action) {
            image
                .resizable()
                .scaledToFit()
                .foregroundStyle(foregroundColor)
                .frame(
                    width: size - iconInset * 2,
                    height: size - iconInset * 2
                )
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
        .buttonBorderShape(.circle)
        .buttonStyle(.glass)
        .contentShape(Circle())
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension DWCircleButton {
    /// 버튼의 크기를 설정합니다
    /// - Parameter size: 버튼의 width, height 공통 크기
    @discardableResult
    func setupSize(_ size: CGFloat) -> Self {
        var view = self
        view.size = size
        return view
    }
    
    /// 내부 아이콘의 여백(inset)을 설정합니다.
    ///
    /// 버튼 내부에서 아이콘이 차지하는 영역의 비율을 제어합니다.
    /// 이 값이 커질수록 아이콘이 작게 보이며,
    /// 버튼의 전체 프레임(`size`) 안쪽에 동일한 여백이 적용됩니다.
    ///
    /// - Parameter inset: 버튼 가장자리로부터 아이콘까지의 여백 값(포인트 단위)입니다.
    ///   예를 들어 `size = 44`, `inset = 12`이면 실제 아이콘의 크기는 `44 - (12 × 2) = 20pt`로 렌더링됩니다.
    @discardableResult
    func setupIconInset(_ inset: CGFloat) -> Self {
        var view = self
        view.iconInset = inset
        return view
    }
    
    /// 버튼의 아이콘의 색상을 설정합니다
    /// - Parameter color: 버튼의 아이콘 색
    @discardableResult
    func setupForegroundColor(_ color: Color) -> Self {
        var view = self
        view.foregroundColor = color
        return view
    }
}

// #Preview {
//    DWCircleButton(image: Image(.setting), action: {})
// }
