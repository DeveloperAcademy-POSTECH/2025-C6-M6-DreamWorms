//
//  TrackingSelectionScreen.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct TrackingSelectionScreen: View {
    let locations: [Location]
    
    @Binding var slots: [String?]
    @Binding var slotLocationIds: [UUID?]
    @Binding var activeSlotIndex: Int?
    
    let namespace: Namespace.ID
    let onBack: () -> Void
    let onDone: () -> Void
        
    private var selectedLocationIDSet: Set<UUID> {
        Set(slotLocationIds.compactMap(\.self))
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            TrackingNaverMapView(
                locations: locations,
                selectedLocationIDs: selectedLocationIDSet,
                cctvMarkers: [],
                onLocationTapped: handleLocationTapped
            )
            .matchedGeometryEffect(id: "trackingMap", in: namespace)
            .ignoresSafeArea()
        }
        .safeAreaInset(edge: .top) {
            CCTVSelectionPanel(
                slotTitles: $slots,
                onSelectSlot: { index in
                    activeSlotIndex = index
                },
                onBack: onBack,
                onDone: onDone,
                onClearSlot: { index in
                    clearSlot(at: index)
                }
            )
        }
    }
}

// MARK: - Private Methods

private extension TrackingSelectionScreen {
    func handleLocationTapped(id: UUID, name: String) {
        // 1) 사용자가 특정 슬롯을 선택해 둔 경우 그 슬롯에 채우기
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
}
