//
//  DWTabBar.swift
//  SUSA24-iOS
//
//  Created by mini on 11/4/25.
//

import SwiftUI

struct DWTabBar<Content: View>: View {
    @Binding var activeTab: MainTabIdentifier
    let showDivider: Bool
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let bottomPadding = safeArea.bottom / 5

            VStack(spacing: 0) {
                if activeTab == .map {
                    content()
                    if showDivider { Divider() }
                } else {
                    Spacer(minLength: 0)
                }

                dwTabBar()
                    .padding(.bottom, bottomPadding)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    @ViewBuilder
    func dwTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(MainTabIdentifier.allCases, id: \.title) { tab in
                VStack(spacing: 4) {
                    tab.icon
                        .font(.system(size: 20))
                    
                    Text(tab.title)
                        .font(.bodyMedium10)
                }
                .foregroundStyle(activeTab == tab ? .primaryNormal : .labelNeutral)
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
                .onTapGesture { activeTab = tab }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 10)
    }
}
