//
//  DWCircleButton.swift
//  DreamWorms-iOS
//
//  Created by Muchan Kim on 10/19/25.
//

import SwiftUI

struct DWCircleButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray44)
        }
        .frame(width: 44, height: 44)
        .background(Color.white)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        DWCircleButton(systemImage: "chevron.left") {
            print("뒤로가기")
        }
        
        DWCircleButton(systemImage: "xmark") {
            print("닫기")
        }
    }
    .padding()
    .background(Color.grayF2)
}
