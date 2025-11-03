//
//  DWTabBar.swift
//  SUSA24-iOS
//
//  Created by mini on 11/4/25.
//

import SwiftUI

struct DWTabBar: View {
    @Binding var activeTab: MainTabIdentifier

    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let bottomPadding = safeArea.bottom / 5

            VStack(spacing: 0) {
                // TODO: - 해당 Spacer 부분에 이제 타임라인 뷰를 얹으면 됩니다!!
                Spacer(minLength: 0)
                dwTabBar()
                    .padding(.bottom, bottomPadding)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    @ViewBuilder
    func dwTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(MainTabIdentifier.allCases, id: \.title) { tab in
                VStack(spacing: 4) {
                    tab.icon
                        .font(.title3)
                    
                    Text(tab.title)
                        .font(.bodyMedium10)
                }
                .foregroundStyle(activeTab == tab ? .primaryNormal : .labelNeutral)
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    activeTab = tab
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
    }
}

//#Preview {
//    DWTabBar(activeTab: .constant(.map))
//}
