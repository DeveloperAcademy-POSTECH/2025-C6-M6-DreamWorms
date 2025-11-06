//
//  ThumbnailButton.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//

import SwiftUI

struct ThumbnailButton: View {
    
    let image: Image
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Rectangle()
                .foregroundColor(.cameraThumbnail)
                .frame(width: 56, height: 56)
                .cornerRadius(8)
                .overlay(
                    image
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                )
        }
    }
}
