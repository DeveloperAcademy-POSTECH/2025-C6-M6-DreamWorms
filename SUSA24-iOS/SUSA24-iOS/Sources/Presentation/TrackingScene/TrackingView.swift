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
    
    @Environment(TabBarVisibility.self)
    private var tabBarVisibility
    
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
    
    /// 완료 눌렀을 때 결과 화면으로 전환 여부
    @State private var isResultMode: Bool = false
    
    /// 맵 크기 전환용 네임스페이스
    @Namespace private var mapNamespace
    
    private var selectedLocationIDSet: Set<UUID> {
        Set(slotLocationIds.compactMap(\.self))
    }
    
    // MARK: - View
    
    var body: some View {
        Group {
            if isResultMode {
                TrackingResultScreen(
                    locations: timeLineStore.state.locations,
                    selectedLocationIDs: selectedLocationIDSet,
                    slots: slots,
                    cctvMarkers: timeLineStore.state.cctvMarkers,
                    isCCTVLoading: timeLineStore.state.isCCTVLoading,
                    namespace: mapNamespace,
                    onBack: {
                        resetTrackingState()
                        isResultMode = false
                    }
                )
            } else {
                TrackingSelectionScreen(
                    locations: timeLineStore.state.locations,
                    slots: $slots,
                    slotLocationIds: $slotLocationIds,
                    activeSlotIndex: $activeSlotIndex,
                    namespace: mapNamespace,
                    onBack: { coordinator.pop() },
                    onDone: {
                        guard slots.allSatisfy({ $0 != nil }) else { return }
                        
                        let selectedLocations = timeLineStore.state.locations.filter {
                            selectedLocationIDSet.contains($0.id)
                        }
                        timeLineStore.send(.requestCCTV(selectedLocations))
                        
                        withAnimation(
                            .spring(response: 0.5, dampingFraction: 0.85)
                        ) {
                            isResultMode = true
                        }
                    }
                )
            }
        }
        .task {
            timeLineStore.send(.onAppear(caseID))
        }
        .onChange(of: isResultMode) { _, isResult in
            isResult ? tabBarVisibility.hide() : tabBarVisibility.show()
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
    
    /// 슬롯 하나 비우고, 선택된 항목들을 앞으로 당겨주는 로직
    func clearSlot(at index: Int) {
        guard slots.indices.contains(index) else { return }
        
        // 1) 해당 슬롯 비우기
        slots[index] = nil
        slotLocationIds[index] = nil
        
        // 2) 남아 있는 것들만 순서대로 모으기
        var newTitles: [String?] = []
        var newIds: [UUID?] = []
        
        for i in slots.indices {
            if let id = slotLocationIds[i],
               let title = slots[i]
            {
                newTitles.append(title)
                newIds.append(id)
            }
        }
        
        // 3) 나머지는 nil 로 채워서 길이 유지
        while newTitles.count < slots.count {
            newTitles.append(nil)
            newIds.append(nil)
        }
        
        slots = newTitles
        slotLocationIds = newIds
    }
    
    /// 가장 처음 상태로 돌아가는 메서드
    func resetTrackingState() {
        slots = [nil, nil, nil]
        slotLocationIds = [nil, nil, nil]
        activeSlotIndex = nil
    }
}
