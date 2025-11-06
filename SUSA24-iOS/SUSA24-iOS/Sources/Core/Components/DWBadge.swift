//
//  DWBadge.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import SwiftUI

struct DWBadge: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.primaryNormal)
                .frame(width: 28, height: 28)
            
            Text("\(count)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
        .offset(x: 12, y: -12)
    }
}

struct DWBadgeModifier: ViewModifier {
    let count: Int
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            
            if count > 0 {
                DWBadge(count: count)
            }
        }
    }
}

extension View {
    func dwBadge(_ count: Int) -> some View {
        modifier(DWBadgeModifier(count: count))
    }
}

struct DWBadgePreview: View {
    var body: some View {
        Image(systemName: "bell.fill")
            .resizable()
            .frame(width: 40, height: 40)
            .dwBadge(7)
    }
}

//#Preview {
//    DWBadgePreview()
//}
