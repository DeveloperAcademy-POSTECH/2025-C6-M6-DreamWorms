//
//  CaseListEmpty.swift
//  SUSA24-iOS
//
//  Created by mini on 11/11/25.
//

import SwiftUI

struct CaseListEmpty: View {
    var body: some View {
        VStack(spacing: 26) {
            Image(.imgEmpty)
                .resizable()
                .scaledToFit()
                .frame(height: 70)
            
            VStack(spacing: 4) {
                Text(.caseListEmptyTitle)
                    .font(.titleSemiBold16)
                    .foregroundStyle(.labelNeutral)
                Text(.caseListEmptyDescription)
                    .font(.bodyMedium14)
                    .foregroundStyle(.labelAssistive)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//#Preview {
//    CaseListEmpty()
//}
