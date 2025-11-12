//
//  CameraController.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import SwiftUI

struct CameraController: View {
    let count: Int
    var uiImage: UIImage?
    // 촬영 중인가?
    let isCapturing: Bool
    
    let onDetailsTapped: () -> Void
    let onPhotoCaptureTapped: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                ThumbnailButton(
                    count: count,
                    uiImage: uiImage,
                    action: onDetailsTapped
                )
                .disabled(count == 0)
                .dwBadge(count)
                
                Spacer()
            }
            .padding(.leading, 49)
            
            CaptureButton(action: onPhotoCaptureTapped)
                .disabled(isCapturing)
                .opacity(isCapturing ? 0.5 : 1.0)
        }
        .frame(maxWidth: .infinity)
    }
}

// #Preview {
//    CameraController(
//        count: 3,
//        uiImage: nil,
//        isCapturing: false,
//        onDetailsTapped: {},
//        onPhotoCaptureTapped: {}
//    )
// }
