//
//  View+ZoomGesture.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/23/25.
//

import SwiftUI

extension View {
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
