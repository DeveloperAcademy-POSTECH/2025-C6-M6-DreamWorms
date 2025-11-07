//
//  OnePageStickyHeader.swift
//  SUSA24-iOS
//
//  Created by mini on 11/5/25.
//

import SwiftUI

struct OnePageStickyHeader: View {
    let suspectName: String
    let crime: String
    @Binding var selection: Category
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(suspectName)
                    .font(.titleSemiBold20)
                    .foregroundStyle(.labelNormal)
                Text(crime)
                    .font(.bodyMedium16)
                    .foregroundStyle(.labelAlternative)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 27)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 8) {
                    ForEach(Category.allCases) { cat in
                        DWSelectPin(
                            text: "\(cat.title) 12",
                            isSelected: selection == cat,
                            action: { selection = cat }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .ignoresSafeArea(edges: .top)
    }
}
