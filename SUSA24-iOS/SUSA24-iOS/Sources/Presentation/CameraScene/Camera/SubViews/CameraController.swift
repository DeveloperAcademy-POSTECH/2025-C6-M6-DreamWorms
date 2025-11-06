//
//  CameraController.swift (수정 필요)
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import SwiftUI

struct CameraController: View {
    
    var count: Int = 2
    var uiImage: UIImage? = nil
    
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
                .dwBadge(count)
                
                Spacer()
            }
            .padding(.leading, 49)
            
            CaptureButton(action: onPhotoCaptureTapped)
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    CameraController(count: 3, uiImage: nil, onDetailsTapped: {}, onPhotoCaptureTapped: {})
//}
