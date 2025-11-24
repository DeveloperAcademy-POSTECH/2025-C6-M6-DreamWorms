//
//  ScanListHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import SwiftUI

struct ScanListHeader: View {
    let onBackTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DWGlassEffectCircleButton(
                    image: Image(.back),
                    action: onBackTapped
                )
                Spacer()
            }
            .padding(.bottom, 15)
            .padding(.horizontal, 16)

            Text(.scanListTitle)
                .font(.titleSemiBold22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
        }
    }
}

//#Preview {
//    ScanListHeader(onBackTapped: {})
//}
