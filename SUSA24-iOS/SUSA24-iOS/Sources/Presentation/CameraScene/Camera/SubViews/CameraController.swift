//
//  CameraController.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import SwiftUI

struct CameraController: View {
    
    var count: Int = 2
    var image: Image = Image(.icnThumbnail)
    
    let onDetailsTapped: () -> Void
    let onPhotoCaptureTapped: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                ThumbnailButton(
                    image: image,
                    action: onDetailsTapped
                )
                .dwBadge(count)
                
                Spacer()
            }
            .padding(.leading, 49)
            
            CaptureButton(action: onPhotoCaptureTapped)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CameraController(image: Image(.camera), onDetailsTapped: {}, onPhotoCaptureTapped: {})
}
