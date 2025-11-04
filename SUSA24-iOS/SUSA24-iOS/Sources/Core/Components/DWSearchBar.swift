//
//  DWSearchBar.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import SwiftUI

/// 지도 화면에서 사용하는 검색 바 컴포넌트
struct DWSearchBar: View {
    var placeholder: String = String(localized: .placeholderSearch)
    var isTapped: () -> Void

    var leadingPadding: CGFloat = 16
    var trailingPadding: CGFloat = 12
    var height: CGFloat = 46
    var isInteractiveEffect: Bool = true

    var iconImage: Image = Image(.search)
    var iconColor: Color = .labelNeutral

    var body: some View {
        Button {
            isTapped()
        } label: {
            HStack {
                Text(placeholder)
                    .font(.bodyMedium16)
                    .foregroundStyle(.labelAssistive)
                    .padding(.leading, leadingPadding)

                Spacer()

                iconImage
                    .frame(width: 24, height: 24)
                    .foregroundStyle(iconColor)
                    .padding(.trailing, trailingPadding)
            }
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .glassEffect(isInteractiveEffect ? .regular.interactive() : .regular)
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension DWSearchBar {
    
    /// 검색 바의 높이를 설정합니다.
    /// - Parameter height: 검색 바의 높이 값
    @discardableResult
    func setupHeight(_ height: CGFloat) -> Self {
        var view = self
        view.height = height
        return view
    }
    
    /// 플레이스홀더 텍스트를 설정합니다.
    /// - Parameter placeholder: 검색 바에 표시할 플레이스홀더 텍스트
    @discardableResult
    func setupPlaceholder(_ placeholder: String) -> Self {
        var view = self
        view.placeholder = placeholder
        return view
    }
    
    /// 텍스트 왼쪽 패딩을 설정합니다.
    /// - Parameter padding: 텍스트의 왼쪽 패딩 값
    @discardableResult
    func setupLeadingPadding(_ padding: CGFloat) -> Self {
        var view = self
        view.leadingPadding = padding
        return view
    }
    
    /// 돋보기 아이콘의 오른쪽 패딩을 설정합니다.
    /// - Parameter padding: 돋보기 아이콘의 오른쪽 패딩 값
    @discardableResult
    func setupTrailingPadding(_ padding: CGFloat) -> Self {
        var view = self
        view.trailingPadding = padding
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
}
