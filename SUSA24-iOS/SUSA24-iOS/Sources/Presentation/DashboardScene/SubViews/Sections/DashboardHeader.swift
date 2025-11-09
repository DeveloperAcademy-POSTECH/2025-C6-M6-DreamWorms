//
//  DashboardHeader.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import SwiftUI

struct DashboardHeader: View {
    let title: String
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.titleSemiBold22)
                .kerning(-0.44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 80)
                .padding(.bottom, 38)
                .padding(.horizontal, 16)
        }
        .overlay(alignment: .topLeading) {
            HStack {
                DWGlassEffectCircleButton(
                    image: Image(.back),
                    action: onBack
                )
                .setupSize(44)
                .setupIconSize(18)
                .padding(.leading, 16)
                
                Spacer()
            }
            .safeAreaInset(edge: .top) {
                Color.white.ignoresSafeArea().frame(height: 0)
            }
        }
    }
}

// #Preview {
//    DashboardHeader(title: String(localized: .testAnalyze), onBack: {})
// }
