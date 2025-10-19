//
//  CaseAddHeader.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/19/25.
//

import SwiftUI

struct CaseAddHeader: View {
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                Image(.icnClose24)
                    .renderingMode(.template)
                    .foregroundStyle(.gray44)
                    .frame(width: 44, height: 44)
                    .background(.white, in: Circle())
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 2)
            }
        }
        .padding(.top, 10)
        .padding([.bottom, .horizontal], 16)

        HStack {
            Text(.caseAddTitle)
                .font(.pretendardSemiBold(size: 24))
                .foregroundStyle(.black22)
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.bottom, 36)
    }
}

#Preview {
    CaseAddHeader(onClose: {})
}
