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
    
    // Pinch Zoom 상태
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    // MARK: - View

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 상단 헤더
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("\(currentIndex + 1) / \(photos.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                
                // MARK: - 이미지 영역 (Pinch Zoom 가능)
                ZStack {
                    Color.white
                    
                    if !photos.isEmpty {
                        Color.gray
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                            .scaleEffect(scale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        scale *= delta
                                        lastScale = value
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            scale = 1.0
                                        }
                                        lastScale = 1.0
                                    }
                            )
                    }
                }
                .frame(maxHeight: .infinity)
                
                // MARK: - 하단 탐색 및 정보
                VStack(spacing: 12) {
                    // 스와이프 힌트 텍스트
                    Text("좌우로 스와이프하여 사진을 이동합니다")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // 썸네일 스크롤 뷰
                    if !photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(0..<photos.count, id: \.self) { index in
                                    Color.gray
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(
                                                    currentIndex == index ? Color.blue : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                currentIndex = index
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        handleSwipe(value)
                    }
            )
        }
    }
    
    // MARK: - 스와이프 핸들링
    private func handleSwipe(_ gesture: DragGesture.Value) {
        let horizontalAmount = gesture.translation.width
        
        if horizontalAmount < -50 {
            // 왼쪽으로 스와이프 -> 다음 사진
            if currentIndex < photos.count - 1 {
                withAnimation {
                    currentIndex += 1
                }
            }
        } else if horizontalAmount > 50 {
            // 오른쪽으로 스와이프 -> 이전 사진
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
