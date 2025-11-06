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
    @FocusState private var isSearchFocused: Bool
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            if !store.state.isMinimized {
                TimeLineBottomSheetHeader(
                    title: store.state.caseName,
                    suspectName: store.state.suspectName,
                    locationCount: store.state.totalLocationCount
                )
                .padding(.top, 12)
                .padding(.bottom, 16)
                if !store.state.isEmpty {
                    TimeLineSearchBar(store: store,
                                      isSearchFocused: $isSearchFocused)
                    .padding(.bottom, 16)
                    
                    TimeLineDateChipList (
                        dates: store.state.groupedLocations.map { $0.date },
                        onDateTapped: { date in
                            store.send(.scrollToDate(date))
                        }
                    )
                    .padding(.bottom, 24)
                }
            }
            
            // MARK: - contentSection
            if store.state.isEmpty {
                TimeLineEmptyState(
                    message:.bottomSheetNoCellData
                )
                .setupRadius(18)
                .setupBackground(.mainBackground)
                .padding(.horizontal, 16)
                .padding(16)
                .opacity(0.5)
            }
            else {
                TimeLineScrollContentView(
                    groupedLocations: store.state.groupedLocations,
                    scrollTargetID: store.state.scrollTarget?.dateID,
                    onLocationTapped: { location in
                        store.send(.locationTapped(location))
                    }
                )
            }
        }
        .task {
            @MainActor in
            store.send(.onAppear)
        }
    }
    
    // MARK: - Helper Methods
    
    private func determineColorState(
        for location: Location,
        in groups: [LocationGroupedByDate]
    ) -> TimeLineColorStickState {
        return .normal
    }
}
// MARK: - Extension Methods

extension TimeLineView {}

// MARK: - Private Extension Methods

private extension TimeLineView {}

// MARK: - Preview

//#Preview {
    //    let mockCase = Case(
    //        id: UUID(),
    //        number: "12-2025",
    //        name: "택시 상습추행",
    //        crime: "성추행",
    //        suspect: "김꿈틀"
    //    )
    //
    //    // 날짜별로 5개씩 Location 생성
    //    let mockLocations: [Location] = [
    //        // 10월 30일 - 5개
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 중구 동성로2가",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8714, pointLongitude: 128.5948,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 30, hour: 13, minute: 44)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 수성구 범어동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8581, pointLongitude: 128.6311,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 30, hour: 14, minute: 23)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 달서구 성당동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8284, pointLongitude: 128.5351,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 30, hour: 15, minute: 10)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 북구 칠성동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8861, pointLongitude: 128.5825,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 30, hour: 16, minute: 45)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 동구 신암동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8923, pointLongitude: 128.6345,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 30, hour: 18, minute: 20)),
    //            colorType: 1
    //        ),
    //
    //        // 10월 29일 - 5개
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 중구 삼덕동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8668, pointLongitude: 128.5975,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 29, hour: 10, minute: 30)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 수성구 만촌동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8534, pointLongitude: 128.6168,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 29, hour: 12, minute: 15)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 달서구 두류동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8420, pointLongitude: 128.5589,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 29, hour: 14, minute: 50)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 북구 침산동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8978, pointLongitude: 128.5642,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 29, hour: 16, minute: 35)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 달서구 월성동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8156, pointLongitude: 128.5234,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 29, hour: 18, minute: 10)),
    //            colorType: 1
    //        ),
    //
    //        // 10월 28일 - 5개
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 중구 대봉동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8589, pointLongitude: 128.6045,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 28, hour: 9, minute: 20)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 동구 신천동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8762, pointLongitude: 128.6358,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 28, hour: 11, minute: 40)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 수성구 범물동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8123, pointLongitude: 128.6789,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 28, hour: 13, minute: 25)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 북구 산격동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8945, pointLongitude: 128.6123,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 28, hour: 15, minute: 55)),
    //            colorType: 1
    //        ),
    //        Location(
    //            id: UUID(),
    //            address: "대구광역시 달서구 이곡동",
    //            title: nil, note: nil,
    //            pointLatitude: 35.8234, pointLongitude: 128.5456,
    //            boxMinLatitude: nil, boxMinLongitude: nil, boxMaxLatitude: nil, boxMaxLongitude: nil,
    //            locationType: 2,
    //            receivedAt: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 28, hour: 17, minute: 30)),
    //            colorType: 1
    //        ),
    //    ]
    //
    //    let store = DWStore(
    //        initialState: TimeLineFeature.State(
    //            caseInfo: mockCase,
    //            locations: mockLocations
    //        ),
    //        reducer: TimeLineFeature()
    //    )
    //
    //    return TimeLineView(store: store)
//}
