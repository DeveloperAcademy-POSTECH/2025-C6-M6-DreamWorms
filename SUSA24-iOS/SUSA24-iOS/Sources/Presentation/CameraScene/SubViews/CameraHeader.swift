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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DWCircleButton(
                    image: Image(.back),
                    action: onBackTapped
                )
                Spacer()
                DWGlassEffectCircleButton(
                    action: onScanTapped,
                    icon: Image(.checkmark)
                )
                .setupIconColor(.labelColorNormal)
                .setupInteractiveEffect(true)
                .setupbuttonBackgroundColor(.primaryNormal)
            }
        }
        .padding(.horizontal, 16)
    }
}

//#Preview {
//    CameraHeader(onBackTapped: {}, onScanTapped: {})
//}
