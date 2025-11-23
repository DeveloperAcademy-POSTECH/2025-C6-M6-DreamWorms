//
//  ZoomableImageView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/10/25.
//

import SwiftUI

// MARK: - View

struct ZoomableImageView: View {
    let image: UIImage
    let screenSize: CGSize
    
    @State private var zoomState = ZoomState()
    
    var body: some View {
        let scale = screenSize.height > 0 ? screenSize.height / image.size.height : 1.0
        let scaledWidth = image.size.width * scale
        let scaledHeight = screenSize.height
        
        Color.clear
            .frame(width: screenSize.width, height: screenSize.height)
            .overlay(
                Group {
                    if screenSize != .zero {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: scaledWidth, height: scaledHeight)
                            .scaleEffect(zoomState.scale, anchor: zoomState.anchor)
                            .offset(zoomState.offset)
                            .applyZoomGestures(
                                zoomState: $zoomState,
                                containerSize: screenSize,
                                imageSize: CGSize(width: scaledWidth, height: scaledHeight)
                            )
                    }
                }
            )
            .clipped()
            .ignoresSafeArea(.all)
    }
}

// MARK: - Zoom Gesture Modifier

struct ZoomGestureModifier: ViewModifier {
    @Binding var zoomState: ZoomState
    let containerSize: CGSize
    let imageSize: CGSize
    
    @State private var isPinching: Bool = false
    @State private var initialPinchScale: CGFloat = 1.0
    
    // 더블 탭 확대 배율
    private let doubleTapZoomScale: CGFloat = 2.5
    
    func body(content: Content) -> some View {
        content
            // 더블 탭 제스처 추가
            .onTapGesture(count: 2) { handleDoubleTap() }
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
    
    // MARK: - Double Tap Handler
    
    private func handleDoubleTap() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if zoomState.scale > 1.0 {
                // 현재 확대되어 있으면 -> 리셋
                zoomState.scale = 1.0
                zoomState.lastScale = 1.0
                zoomState.offset = .zero
                zoomState.lastOffset = .zero
                zoomState.anchor = .center
            } else {
                // 현재 축소 상태면 -> 확대
                zoomState.scale = doubleTapZoomScale
                zoomState.lastScale = doubleTapZoomScale
                zoomState.anchor = .center
            }
        }
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
    
    private func handleMagnificationEnded(_: CGFloat) {
        if isPinching {
            zoomState.scale = min(max(zoomState.scale, 1.0), 5.0)
            zoomState.lastScale = zoomState.scale
            
            if zoomState.scale == 1.0 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    zoomState.offset = .zero
                    zoomState.lastOffset = .zero
                    zoomState.anchor = .center
                }
            } else {
                // zoom 상태에서도 경계 체크
                let clampedOffset = clampOffset(zoomState.offset)
                if clampedOffset != zoomState.offset {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        zoomState.offset = clampedOffset
                        zoomState.lastOffset = clampedOffset
                    }
                }
            }
        }
        isPinching = false
        initialPinchScale = 1.0
    }
    
    private func handleDragForPan(_ value: DragGesture.Value) {
        guard zoomState.scale > 1.0 else { return }
        
        let newOffset = CGSize(
            width: zoomState.lastOffset.width + value.translation.width,
            height: zoomState.lastOffset.height + value.translation.height
        )
        
        zoomState.offset = clampOffset(newOffset)
    }
    
    private func handleDragEnded(_: DragGesture.Value) {
        zoomState.lastOffset = zoomState.offset
    }
    
    // MARK: - Offset Clamping
    
    private func clampOffset(_ offset: CGSize) -> CGSize {
        // 확대된 이미지의 실제 크기
        let zoomedWidth = imageSize.width * zoomState.scale
        let zoomedHeight = imageSize.height * zoomState.scale
        
        // 드래그 가능한 최대 거리 계산
        let maxOffsetX = max(0, (zoomedWidth - containerSize.width) / 2)
        let maxOffsetY = max(0, (zoomedHeight - containerSize.height) / 2)
        
        // offset 제한
        let clampedX = min(max(offset.width, -maxOffsetX), maxOffsetX)
        let clampedY = min(max(offset.height, -maxOffsetY), maxOffsetY)
        
        return CGSize(width: clampedX, height: clampedY)
    }
}
