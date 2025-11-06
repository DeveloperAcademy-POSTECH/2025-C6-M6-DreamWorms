//
//  CircleBadgeModifier.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/7/25.
//


import SwiftUI

struct CircleBadgeModifier: ViewModifier {
    let count: Int
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            
            if count > 0 {
                ZStack {
                    Circle()
                        .fill(.primaryNormal)
                        .frame(width: 28, height: 28)
                    
                    Text("\(count)")
                        .font(.numberSemiBold14)
                        .foregroundColor(.white)
                }
                .offset(x: 12, y: -12)
            }
        }
    }
}

extension View {
    func circleBadge(_ count: Int) -> some View {
        modifier(CircleBadgeModifier(count: count))
    }
}

struct CircleBadgeExampleView: View {
    @State private var count = 1
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "bell.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .circleBadge(count)
        }
        .padding()
    }
}

//#Preview {
//    CircleBadgeExampleView()
//}
