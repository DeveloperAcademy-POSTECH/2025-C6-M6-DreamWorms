//
//  CaseListHeader.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct CaseListHeader: View {
    let onSettingTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                DWCircleButton(
                    image: Image(.setting),
                    action: onSettingTapped
                )
            }
            
            Text(.caseListNavigationTitle)
                .font(.titleSemiBold22)
                .kerning(-0.44)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 24)
        .padding(.trailing, 26)
    }
}

// #Preview {
//    CaseListHeader(onSettingTapped: {})
// }
