//
//  TrackingView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct TrackingView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var timeLineStore: DWStore<TrackingFeature>
    
    // MARK: - Properties
    
    let caseID: UUID
    
    /// 슬롯에 표시할 텍스트
    @State private var slots: [String?] = [nil, nil, nil]
    /// 각 슬롯이 참조하는 Location ID
    @State private var slotLocationIds: [UUID?] = [nil, nil, nil]
    /// 사용자가 지금 선택 중인 슬롯 인덱스
    @State private var activeSlotIndex: Int? = nil
    
    private var selectedLocationIDSet: Set<UUID> {
        Set(slotLocationIds.compactMap(\.self))
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            // 배경: 네이버 지도
            TrackingNaverMapView(
                locations: timeLineStore.state.locations,
                selectedLocationIDs: selectedLocationIDSet
            ) { tappedId, name in
                handleLocationTapped(id: tappedId, name: name)
            }
            .ignoresSafeArea()
        }
        // 상단 CCTV 선택 패널
        .safeAreaInset(edge: .top) {
            CCTVSelectionPanel(
                slotTitles: $slots,
                onSelectSlot: { index in
                    // 이 슬롯에 다음 탭되는 핀을 바인딩
                    activeSlotIndex = index
                },
                onBack: { coordinator.pop() },
                onDone: {
                    // 완료 시점에 선택된 Location 들을 사용
                    print("완료: \(slotLocationIds)")
                    // coordinator.pop() 등 로직 연결 가능
                }
            )
        }
        .task {
            timeLineStore.send(.onAppear(caseID))
        }
    }
}

// MARK: - Extension Methods

extension TrackingView {}

// MARK: - Private Extension Methods

private extension TrackingView {
    func handleLocationTapped(id: UUID, name: String) {
        // 1) 우선 사용자가 특정 슬롯을 선택해 둔 경우 그 슬롯에 채우기
        if let index = activeSlotIndex {
            slots[index] = name
            slotLocationIds[index] = id
            activeSlotIndex = nil
            return
        }
        
        // 2) 아니면 첫 번째 비어있는 슬롯에 채우기
        if let emptyIndex = slots.firstIndex(where: { $0 == nil }) {
            slots[emptyIndex] = name
            slotLocationIds[emptyIndex] = id
            return
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TrackingView(
            timeLineStore: DWStore(
                initialState: TrackingFeature.State(),
                reducer: TrackingFeature(repository: MockLocationRepository())
            ),
            caseID: UUID()
        )
        .environment(AppCoordinator())
    }
}
