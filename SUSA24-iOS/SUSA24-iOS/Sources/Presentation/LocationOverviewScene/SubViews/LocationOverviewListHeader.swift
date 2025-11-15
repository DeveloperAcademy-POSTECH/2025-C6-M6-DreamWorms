//
//  LocationOverviewListHeader.swift
//  SUSA24-iOS
//
//  Created by mini on 11/9/25.
//

import SwiftUI

struct LocationOverviewListHeader: View {
    let selection: Category
    let counts: [Category: Int]
    let onCategoryTap: (Category) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(.locationOverviewTitle)
                .font(.titleSemiBold18)
                .foregroundStyle(.labelNormal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Category.allCases) { category in
                        let count = counts[category, default: 0]
                        DWSelectPin(
                            text: "\(category.title) \(count)",
                            isSelected: selection == category,
                            action: { onCategoryTap(category) }
                        )
                    }
                }
                .padding(.horizontal, 12)
            }
            .scrollDisabled(true)
        }
    }
}
