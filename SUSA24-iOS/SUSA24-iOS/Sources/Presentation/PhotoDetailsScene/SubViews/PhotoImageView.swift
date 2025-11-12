//
//  PhotoImageView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/10/25.
//

import SwiftUI

struct PhotoImageView: View {
    let photo: CapturedPhoto
    @Binding var zoomState: ZoomState
    
    var body: some View {
        if let uiImage = photo.uiImage {
            // GeometryReader 중첩 제거 - ZoomableImageView만 사용
            ZoomableImageView(image: uiImage, zoomState: $zoomState)
        }
    }
}
