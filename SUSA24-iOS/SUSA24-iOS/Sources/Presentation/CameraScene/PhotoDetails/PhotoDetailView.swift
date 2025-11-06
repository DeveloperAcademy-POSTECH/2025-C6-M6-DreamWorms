//
//  PhotoDetailView.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/29/25.
//

import SwiftUI

struct PhotoDetailsView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: PhotoDetailsFeature.State(),
        reducer: PhotoDetailsFeature()
    )

    // MARK: - Properties
    
    @State private var currentIndex: Int = 0
    @State private var photos: [UIImage] = []
    @Environment(\.dismiss) var dismiss
    
    // Pinch Zoom
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    // MARK: - View

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 상단 헤더
                PhotoDetailsHeader(onBackTapped: {}, onDeleteTapped: {})
                
                // TODO: - 이미지 작업
                
                Spacer()
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        handleSwipe(value)
                    }
            )
        }
    }
    
    private func handleSwipe(_ gesture: DragGesture.Value) {
        let horizontalAmount = gesture.translation.width
        
        if horizontalAmount < -50 {
            // 다음 사진
            if currentIndex < photos.count - 1 {
                withAnimation {
                    currentIndex += 1
                }
            }
        } else if horizontalAmount > 50 {
            // 이전 사진
            if currentIndex > 0 {
                withAnimation {
                    currentIndex -= 1
                }
            }
        }
    }
}

// MARK: - Extension Methods

extension PhotoDetailsView {}

// MARK: - Private Extension Methods

private extension PhotoDetailsView {}

// MARK: - Preview

#Preview {
    PhotoDetailsView()
        .environment(AppCoordinator())
}
