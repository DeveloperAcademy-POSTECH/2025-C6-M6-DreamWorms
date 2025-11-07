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
                                    ForEach(Array(group.locations.enumerated()), id: \.element.id) { index, location in
                                        TimeLineDetail(
                                            state: .normal,
                                            caseTitle: location.address,
                                            startTime: location.receivedAt ?? Date(),
                                            endTime: (location.receivedAt ?? Date()).addingTimeInterval(3600),
                                            isLast: index == group.locations.count - 1,
                                            onTap: {
                                                onLocationTapped(location)
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
