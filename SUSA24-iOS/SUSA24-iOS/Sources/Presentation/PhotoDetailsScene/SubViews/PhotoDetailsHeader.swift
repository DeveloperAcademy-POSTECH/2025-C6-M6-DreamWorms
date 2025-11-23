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
                
                HStack {
                    Text("\(currentIndex)/\(totalCount)")
                        .font(.bodyMedium16)
                        .foregroundColor(.labelNormal)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.white.opacity(0.5))
                .cornerRadius(100)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
                
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
