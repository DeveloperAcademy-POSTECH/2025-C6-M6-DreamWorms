//
//  PhotoDetailsHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import SwiftUI

struct PhotoDetailsHeader: View {
    let onBackTapped: () -> Void
    let onDeleteTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DWCircleButton(
                    image: Image(.back),
                    action: onBackTapped
                )
                Spacer()
                DWCircleButton(
                    image: Image(.delete),
                    action: onDeleteTapped
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

//#Preview {
//    PhotoDetailsHeader(onBackTapped: {}, onScanTapped: {})
//}
