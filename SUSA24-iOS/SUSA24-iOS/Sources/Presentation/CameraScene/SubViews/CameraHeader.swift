//
//  CameraHeader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/4/25.
//

import SwiftUI

struct CameraHeader: View {
    let onBackTapped: () -> Void
    let onScanTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                DWCircleButton(
                    image: Image(.back),
                    action: onBackTapped
                )
                Spacer()
                DWCircleButton(
                    image: Image(.check),
                    action: onScanTapped
                )
                
            }
            
            Text(.caseListNavigationTitle)
                .font(.titleSemiBold22)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 24)
        .padding(.trailing, 26)
    }
}

#Preview {
    CameraHeader(onBackTapped: {}, onScanTapped: {})
}



