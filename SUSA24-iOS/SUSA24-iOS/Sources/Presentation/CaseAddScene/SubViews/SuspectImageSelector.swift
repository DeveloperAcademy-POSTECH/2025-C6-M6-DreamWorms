//
//  SuspectImageSelector.swift
//  SUSA24-iOS
//
//  Created by mini on 11/1/25.
//

import SwiftUI

struct SuspectImageSelector: View {
    @Binding var image: Image?
    var onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.gray.opacity(0.3), lineWidth: 1))
            } else {
                Circle()
                    .frame(width: 100, height: 100)
                    .overlay(Image(.imgProfile))
            }

            Button(action: onTap) {
                Image(.camera)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.gray)
                    .padding(8)
                    .background(Circle().fill(.white))
                    .overlay(Circle().stroke(Color.mainAlternative, lineWidth: 1))
            }
            .offset(x: 12, y: 12)
        }
    }
}

//#Preview {
//    SuspectImageSelector(image: .constant(nil), onTap: {})
//}
