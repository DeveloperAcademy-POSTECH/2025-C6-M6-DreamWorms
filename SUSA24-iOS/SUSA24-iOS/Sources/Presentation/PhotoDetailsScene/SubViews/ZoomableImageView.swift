////
////  PhotoImageView.swift
////  SUSA24-iOS
////
////  Created by taeni on 11/10/25.
////
//
// import SwiftUI
//
//// MARK: - View
//
// struct PhotoImageView: View {
//    let photo: CapturedPhoto
//    @State private var screenSize: CGSize = .zero
//    @Binding var zoomState: ZoomState
//
//    var body: some View {
//        if let image = photo.uiImage {
//            let scale = screenSize.height > 0 ? screenSize.height / image.size.height : 1.0
//            var scaledWidth = image.size.width * scale
//            let scaledHeight = screenSize.height
//
//            Image(uiImage: image)
////                .resizable()
////                .frame(width: scaledWidth, height: scaledHeight)
////                .position(x: screenSize.width / 2, y: screenSize.height / 2)
////                .frame(width: screenSize.width, height: screenSize.height)
////                .clipped()
//                .scaleEffect(zoomState.scale, anchor: zoomState.anchor)
//                .offset(zoomState.offset)
//                .applyZoomGestures(
//                    zoomState: $zoomState,
//                    containerSize: screenSize
//                )
//                .onScreen { screen in
//                    if let screen {
//                        screenSize = screen.bounds.size
//                    }
//                }
//
//            // ZoomableImageView(image: uiImage, zoomState: $zoomState)
//        }
//    }
// }
//
//// MARK: - Zoom Gesture Modifier
//
// struct ZoomGestureModifier: ViewModifier {
//    @Binding var zoomState: ZoomState
//    let containerSize: CGSize
//
//    @State private var isPinching: Bool = false
//    @State private var initialPinchScale: CGFloat = 1.0
//
//    func body(content: Content) -> some View {
//        content
//            // Magnification은 항상 적용
//            .gesture(
//                MagnificationGesture()
//                    .onChanged { handleMagnificationChanged($0) }
//                    .onEnded { handleMagnificationEnded($0) }
//            )
//            // DragGesture는 scale > 1일 때만 highPriorityGesture로 적용
//            .highPriorityGesture(
//                DragGesture()
//                    .onChanged { handleDragForPan($0) }
//                    .onEnded { handleDragEnded($0) },
//                including: zoomState.scale > 1.0 ? .all : .subviews
//            )
//    }
//
//    private func handleMagnificationChanged(_ value: CGFloat) {
//        if !isPinching {
//            initialPinchScale = value
//            if abs(value - 1.0) > 0.1 { isPinching = true }
//            else { return }
//        }
//        if isPinching {
//            zoomState.scale = zoomState.lastScale * value
//        }
//    }
//
//    private func handleMagnificationEnded(_: CGFloat) {
//        if isPinching {
//            zoomState.scale = min(max(zoomState.scale, 1.0), 5.0)
//            zoomState.lastScale = zoomState.scale
//
//            if zoomState.scale == 1.0 {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                    zoomState.offset = .zero
//                    zoomState.lastOffset = .zero
//                    zoomState.anchor = .center
//                }
//            }
//        }
//        isPinching = false
//        initialPinchScale = 1.0
//    }
//
//    private func handleDragForPan(_ value: DragGesture.Value) {
//        guard zoomState.scale > 1.0 else { return }
//
//        zoomState.offset = CGSize(
//            width: zoomState.lastOffset.width + value.translation.width,
//            height: zoomState.lastOffset.height + value.translation.height
//        )
//    }
//
//    private func handleDragEnded(_: DragGesture.Value) {
//        zoomState.lastOffset = zoomState.offset
//    }
// }

//
//  PhotoImageView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/10/25.
//

import SwiftUI

// MARK: - View

struct ZoomableImageView: View {
    let image: UIImage
    @Binding var zoomState: ZoomState
    let screenSize: CGSize
    
    var body: some View {
        let scale = screenSize.height > 0 ? screenSize.height / image.size.height : 1.0
        let scaledWidth = image.size.width * scale
        let scaledHeight = screenSize.height
        
        let _ = print("=== PhotoImageView Debug ===")
        let _ = print("Image Size: \(image.size.width) x \(image.size.height)")
        let _ = print("Screen Size: \(screenSize.width) x \(screenSize.height)")
        let _ = print("Scale: \(scale)")
        let _ = print("Scaled Size: \(scaledWidth) x \(scaledHeight)")
        let _ = print("================================")
        
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
                                containerSize: screenSize
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
    
    private func handleDragEnded(_: DragGesture.Value) {
        zoomState.lastOffset = zoomState.offset
    }
}
