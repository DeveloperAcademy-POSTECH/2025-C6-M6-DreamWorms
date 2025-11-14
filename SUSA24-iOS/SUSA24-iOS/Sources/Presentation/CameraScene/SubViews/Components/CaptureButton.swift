//
//  CaptureButton.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//

import SwiftUI

struct CaptureButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.white)
                Circle()
                    .stroke(.cameraStroke, lineWidth: 5)
            }
            .frame(width: 65, height: 65)
        }
    }
}
