//
//  MapLayerContainer.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// 지도 레이어 컨트롤 컨테이너
///
/// 지도 레이어 전환과 현재 위치 재설정 버튼을 세로로 묶은 컨테이너입니다.
struct MapLayerContainer: View {
    /// 지도 레이어 버튼을 탭했을 때 실행되는 액션입니다.
    var onLayerTapped: (() -> Void)? = nil
    /// 현재 위치 재설정 버튼을 탭했을 때 실행되는 액션입니다.
    var onRecenterTapped: (() -> Void)? = nil
    
    var buttonSpacing: CGFloat = 27
    var iconWidth: CGFloat = 23
    var iconHeight: CGFloat = 20
    var verticalPadding: CGFloat = 8
    var horizontalPadding: CGFloat = 2
    var containerWidth: CGFloat = 48
    var containerHeight: CGFloat = 95
    
    var body: some View {
        VStack(spacing: buttonSpacing) {
            Button(action: { onLayerTapped?() }) {
                Image("icn_map_global_layer")
                    .foregroundStyle(.labelNeutral)
                    .frame(width: iconWidth, height: iconHeight)
            }
            
            Button(action: { onRecenterTapped?() }) {
                Image(.myPosition)
                    .foregroundStyle(.labelNeutral)
                    .frame(width: iconWidth, height: iconHeight)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(width: containerWidth, height: containerHeight)
        .glassEffect()
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension MapLayerContainer {
    
    /// 버튼 간격을 설정합니다.
    /// - Parameter spacing: 버튼 간격 값
    @discardableResult
    func setupButtonSpacing(_ spacing: CGFloat) -> Self {
        var view = self
        view.buttonSpacing = spacing
        return view
    }
    
    /// 아이콘 크기를 설정합니다.
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
    
    /// 상하 패딩을 설정합니다.
    /// - Parameter padding: 상하 패딩 값
    @discardableResult
    func setupVerticalPadding(_ padding: CGFloat) -> Self {
        var view = self
        view.verticalPadding = padding
        return view
    }
    
    /// 좌우 패딩을 설정합니다.
    /// - Parameter padding: 좌우 패딩 값
    @discardableResult
    func setupHorizontalPadding(_ padding: CGFloat) -> Self {
        var view = self
        view.horizontalPadding = padding
        return view
    }
    
    /// 컨테이너 크기를 설정합니다.
    /// - Parameters:
    ///   - width: 컨테이너의 너비
    ///   - height: 컨테이너의 높이
    @discardableResult
    func setupContainerSize(width: CGFloat, height: CGFloat) -> Self {
        var view = self
        view.containerWidth = width
        view.containerHeight = height
        return view
    }
}


//#Preview {
//    MapLayerContainer()
//        .padding()
//        .background(Color.blue.opacity(0.3))
//}
