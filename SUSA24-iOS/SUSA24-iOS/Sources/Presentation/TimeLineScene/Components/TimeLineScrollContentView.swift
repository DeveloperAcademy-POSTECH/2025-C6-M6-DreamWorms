//
//  TimeLineScrollContentView.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/7/25.
//

import SwiftUI

struct TimeLineScrollContentView: View {
    let groupedLocations: [LocationGroupedByDate]
    let scrollTargetID: String?
    let onLocationTapped: (Location) -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(groupedLocations) { group in
                        VStack(spacing: 0) {
                            // Scroll Anchor
                            Color.clear
                                .frame(height: 0)
                                .id(group.dateID)
                            
                            // Date Header
                            HStack {
                                TimeLineDateSectionHeader(text: group.headerText)
                                    .font(.bodyMedium16)
                                    .foregroundStyle(.labelNormal)
                                Spacer()
                            }
                            .padding(16)
                            
                            // Location List
                            Section {
                                VStack(spacing: 0) {
                                    ForEach(Array(group.consecutiveGroups.enumerated()), id: \.element.id) { index, consecutiveGroup in
                                        TimeLineDetail(
                                            state: consecutiveGroup.state,
                                            caseTitle: consecutiveGroup.address,
                                            startTime: consecutiveGroup.startTime,
                                            endTime: consecutiveGroup.endTime,
                                            isLast: index == group.consecutiveGroups.count - 1,
                                            onTap: {
                                                onLocationTapped(consecutiveGroup.locations[0])
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            }
                            .background(.labelCoolNormal.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 16)
                    }
                }
                .onChange(of: scrollTargetID) { _, targetID in
                    guard let targetID else { return }
                    withAnimation(.snappy(duration: 0.3)) {
                        proxy.scrollTo(targetID, anchor: .top)
                    }
                }
            }
        }
    }
}
