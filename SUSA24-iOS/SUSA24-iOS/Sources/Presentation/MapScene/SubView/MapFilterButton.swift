//
//  MapFilterButton.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// 지도 필터 토글 버튼
///
/// 아이콘과 텍스트를 포함한 필터 버튼으로, active/inactive 상태를 지원합니다.
/// - active: 파란색 텍스트와 틴트된 배경
/// - inactive: 회색 텍스트와 기본 배경
struct MapFilterButton: View {
    /// 버튼에 표시할 텍스트입니다.
    let text: String
    /// 버튼의 활성화 상태입니다.
    let isActive: Bool
    /// 버튼을 탭했을 때 실행되는 액션입니다.
    let action: () -> Void
    
    /// 버튼에 표시할 아이콘 이미지입니다.
    let iconImage: Image
    /// 좌우 패딩 값입니다.
    var horizontalPadding: CGFloat = 10
    /// 상하 패딩 값입니다.
    var verticalPadding: CGFloat = 9.5
    /// 아이콘과 텍스트 사이 간격입니다.
    var iconTextSpacing: CGFloat = 4
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: iconTextSpacing) {
                iconImage
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isActive ? .primaryNormal : .labelNeutral)
                
                Text(text)
                    .font(.bodyMedium14)
                    .foregroundStyle(isActive ? .primaryNormal : .labelNeutral)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
        .glassEffect(isActive ? .regular.tint(.primaryNormal2) : .regular)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension MapFilterButton {
    /// 좌우 패딩을 설정합니다.
    /// - Parameter padding: 좌우 패딩 값
    @discardableResult
    func setupHorizontalPadding(_ padding: CGFloat) -> Self {
        var view = self
        view.horizontalPadding = padding
        return view
    }
    
    /// 상하 패딩을 설정합니다.
    /// - Parameter padding: 상하 패딩 값
    @discardableResult
    func setupVerticalPadding(_ padding: CGFloat) -> Self {
        var view = self
        view.verticalPadding = padding
        return view
    }
    
    /// 아이콘과 텍스트 사이 간격을 설정합니다.
    /// - Parameter spacing: 아이콘과 텍스트 사이 간격 값
    @discardableResult
    func setupIconTextSpacing(_ spacing: CGFloat) -> Self {
        var view = self
        view.iconTextSpacing = spacing
        return view
    }
}

// #Preview {
//    HStack(spacing: 10) {
//        MapFilterButton(
//            text: "기지국 범위",
//            isActive: true,
//            action: {}
//        )
//        .setupDefaultIcon(Image("icn_cov_default"))
//
//        MapFilterButton(
//            text: "누적 빈도",
//            isActive: false,
//            action: {}
//        )
//        .setupDefaultIcon(Image("icn_freq_default"))
//
//        MapFilterButton(
//            text: "최근 기지국",
//            isActive: false,
//            action: {}
//        )
//        .setupDefaultIcon(Image("icn_cell_default"))
//    }
//    .padding()
// }
//
