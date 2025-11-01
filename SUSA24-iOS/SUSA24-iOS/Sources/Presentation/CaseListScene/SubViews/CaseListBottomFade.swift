//
//  CaseListBottomFade.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct CaseListBottomFade: View {
    let onAddCaseTapped: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            DWButton(
                isEnabled: .constant(true),
                title: String(localized: .buttonAddCase),
                action: onAddCaseTapped
            )
            .setupVerticalPadding(12)
            .setupImage(Image(.plus))
            .frame(width: 114)
            .padding(.trailing, 20)
        }
        .padding(.top, 4)
        .padding(.bottom, 38)
        .ignoresSafeArea()
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black.opacity(0.0), location: 0.00),
                            .init(color: .black.opacity(0.4), location: 0.35),
                            .init(color: .black.opacity(1.0), location: 1.00)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .allowsHitTesting(false)

            LinearGradient(
                colors: [.gradientGray.opacity(0), .black.opacity(0.30)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
        }
    }
}

//#Preview {
//    CaseListBottomFade(onAddCaseTapped: {})
//}
