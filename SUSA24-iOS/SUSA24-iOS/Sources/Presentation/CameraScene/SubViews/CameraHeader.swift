//
//  CameraHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import SwiftUI

struct CameraHeader: View {
    let onBackTapped: () -> Void
    let onScanTapped: () -> Void
    
    let showScanButton: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DWCircleButton(
                    image: Image(.back),
                    action: onBackTapped
                )
                
                Spacer()
                
                if showScanButton {
                    DWGlassEffectCircleButton(
                        image: Image(.checkmark),
                        action: onScanTapped
                    )
                    .setupIconColor(.labelCoolNormal)
                    .setupInteractiveEffect(true)
                    .setupbuttonBackgroundColor(.primaryNormal)
                }
            }
        }
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showScanButton)
    }
}

//#Preview {
//    CameraHeader(onBackTapped: {}, onScanTapped: {})
//}
