//
//  View+ZoomGesture.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/23/25.
//

import SwiftUI

extension View {
    /// 뷰에 **확대/축소(Zoom)** 제스처를 적용합니다.
    ///
    /// - Parameters:
    ///   - zoomState: 현재 확대 상태를 나타내는 바인딩
    ///   - containerSize: 컨테이너(부모 뷰)의 크기
    ///   - imageSize: 원본 이미지의 크기
    func applyZoomGestures(
        zoomState: Binding<ZoomState>,
        containerSize: CGSize,
        imageSize: CGSize
    ) -> some View {
        modifier(
            ZoomGestureModifier(
                zoomState: zoomState,
                containerSize: containerSize,
                imageSize: imageSize
            )
        )
    }
}
