//
//  TimeLineView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct TimeLineView: View {
    
    // MARK: - Dependencies
    
    @State var store: DWStore<TimeLineFeature>
    
    // MARK: - Properties
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            TimeLineBottomSheetHeader(
                title: store.state.caseName,
                suspectName: store.state.suspectName,
                locationCount: store.state.totalLocationCount
            )
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            // 컨텐츠 유무 체크
            if store.state.isEmpty {
                TimeLineEmptyState(
                    message: .bottomSheetNoCellData
                )
                .setupRadius(18)
                .setupBackground(.mainBackground)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .opacity(0.5)
            }
            else {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(store.state.groupedLocations) { group in
                            Section {
                                ForEach(Array(group.locations.enumerated()), id: \.element.id) { index, location in
                                    TimeLineDetail(
                                        state: determineColorState(for: location, in: store.state.groupedLocations),
                                        caseTitle: location.address,
                                        startTime: location.receivedAt ?? Date(),
                                        endTime: (location.receivedAt ?? Date()).addingTimeInterval(3600),
                                        isLast: index == group.locations.count - 1,
                                        onTap: {
                                            store.send(.locationTapped(location))
                                        }
                                    )
                                }
                            } header: {
                                TimeLineDateSectionHeader(text: group.headerText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    // MARK: - Helper Methods
    
    /// 방문 빈도에 따라 색상 상태를 결정합니다.
    private func determineColorState(
        for location: Location,
        in groups: [LocationGroupedByDate]
    ) -> TimeLineColorStickState {
        // TODO: 실제 방문 빈도 로직 구현
        // 현재는 임시로 normal 반환
        return .normal
    }
}

// MARK: - Extension Methods

extension TimeLineView {}

// MARK: - Private Extension Methods

private extension TimeLineView {}

// MARK: - Preview

#Preview {
    let mockCase = Case(
        id: UUID(),
        number: "12-2025",
        name: "택시 상습추행",
        crime: "성추행",
        suspect: "김꿈틀"
    )
    
    let store = DWStore(
        initialState: TimeLineFeature.State(
            caseInfo: mockCase,
            locations: []
        ),
        reducer: TimeLineFeature()
    )
    
    TimeLineView(store: store)
}
