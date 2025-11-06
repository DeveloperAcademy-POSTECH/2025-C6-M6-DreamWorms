//
//  ThumbnailButton.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//

import SwiftUI

// MARK: - Default Thumbnail View

struct DefaultThumbnailView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.cameraThumbnail)
            .frame(width: 56, height: 56)
            .cornerRadius(8)
            .overlay(
                Image(.icnThumbnail)
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Thumbnail Button

struct ThumbnailButton: View {
    
    /// 촬영된 사진의 개수
    let count: Int
    
    /// 썸네일 이미지 (UIImage)
    let uiImage: UIImage?
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if count == 0 {
                DefaultThumbnailView()
            } else {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    DefaultThumbnailView()
                }
            }
        }
    }
}
