//
//  FadingProfileImage.swift
//  SUSA24-iOS
//
//  Created by mini on 11/5/25.
//

import SwiftUI

struct FadingProfileImage: View {
    let suspectImage: Image?
    
    var body: some View {
        VStack(spacing: 14) {
            Group {
                if let suspectImage {
                    suspectImage.resizable()
                        .scaledToFill()
                        .overlay(
                            Circle().stroke(.labelAssistive, lineWidth: 1)
                        )
                } else {
                    Circle()
                        .fill(.clear)
                        .overlay(
                            Image(.imgProfile)
                                .resizable()
                                .scaledToFill()
                                .overlay(
                                    Circle().stroke(.labelAssistive, lineWidth: 1)
                                )
                        )
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 56)
        .padding(.bottom, 16)
        .background(.white)
        .frame(height: 170)
    }
}
