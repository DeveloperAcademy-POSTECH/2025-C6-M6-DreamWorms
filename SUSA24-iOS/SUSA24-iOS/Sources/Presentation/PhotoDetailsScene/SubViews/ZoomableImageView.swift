//
//  ZoomableImageView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

// MARK: - Zoomable Image View

struct ZoomableImageView: View {
    let image: UIImage
    @Binding var zoomState: ZoomState
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            // TODO: 촬영된 이미지가 디바이스 전체 사이즈 크기다보니, width값에 맞추면 뷰에서 hifi 뷰 처럼 보기가 어려운 문제가 있음. -> 검토 필요
                .frame(width: geometry.size.width)
                .scaleEffect(zoomState.scale, anchor: zoomState.anchor)
                .offset(zoomState.offset)
                .applyZoomGestures(
                    zoomState: $zoomState,
                    containerSize: geometry.size
                )
        }
    }
}

// MARK: - Gesture Extension

extension View {
    func applyZoomGestures(
        zoomState: Binding<ZoomState>,
        containerSize: CGSize
    ) -> some View {
        modifier(ZoomGestureModifier(
            zoomState: zoomState,
            containerSize: containerSize
        ))
    }
}

struct ZoomGestureModifier: ViewModifier {
    @Binding var zoomState: ZoomState
    let containerSize: CGSize

    @State private var isPinching: Bool = false
    @State private var initialPinchScale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            // Magnification은 항상 적용
            .gesture(
                MagnificationGesture()
                    .onChanged { handleMagnificationChanged($0) }
                    .onEnded { handleMagnificationEnded($0) }
            )
            // DragGesture는 scale > 1일 때만 highPriorityGesture로 적용
            .highPriorityGesture(
                DragGesture()
                    .onChanged { handleDragForPan($0) }
                    .onEnded { handleDragEnded($0) },
                including: zoomState.scale > 1.0 ? .all : .subviews
            )
    }

    private func handleMagnificationChanged(_ value: CGFloat) {
        if !isPinching {
            initialPinchScale = value
            if abs(value - 1.0) > 0.1 { isPinching = true }
            else { return }
        }
        if isPinching {
            zoomState.scale = zoomState.lastScale * value
        }
    }

    private func handleMagnificationEnded(_ value: CGFloat) {
        if isPinching {
            zoomState.scale = min(max(zoomState.scale, 1.0), 5.0)
            zoomState.lastScale = zoomState.scale

            if zoomState.scale == 1.0 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    zoomState.offset = .zero
                    zoomState.lastOffset = .zero
                    zoomState.anchor = .center
                }
            }
        }
        isPinching = false
        initialPinchScale = 1.0
    }

    private func handleDragForPan(_ value: DragGesture.Value) {
        guard zoomState.scale > 1.0 else { return }

        zoomState.offset = CGSize(
            width: zoomState.lastOffset.width + value.translation.width,
            height: zoomState.lastOffset.height + value.translation.height
        )
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        zoomState.lastOffset = zoomState.offset
    }
}
