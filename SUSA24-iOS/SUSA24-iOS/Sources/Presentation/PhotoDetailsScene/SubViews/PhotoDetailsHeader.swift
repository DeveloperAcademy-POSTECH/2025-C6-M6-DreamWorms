//
//  PhotoDetailsHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import SwiftUI

struct PhotoDetailsHeader: View {
    let currentIndex: Int
    let totalCount: Int
    
    let onBackTapped: () -> Void
    let onDeleteTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DWGlassEffectCircleButton(
                    image: Image(.back),
                    action: onBackTapped
                )
                Spacer()
                
                Text("\(currentIndex)/\(totalCount)")
                    .font(.bodyMedium16)
                    .foregroundColor(.labelNormal)
                
                Spacer()
                
                DWGlassEffectCircleButton(
                    image: Image(.delete),
                    action: onDeleteTapped
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

// #Preview {
//    PhotoDetailsHeader(currentIndex: 1, totalCount: 9, onBackTapped: {}, onDeleteTapped: {})
// }
