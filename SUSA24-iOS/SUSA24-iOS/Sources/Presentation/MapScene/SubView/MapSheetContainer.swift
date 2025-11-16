//
//  MapSheetContainer.swift
//

import SwiftUI

struct MapSheetContainer: View {
    let state: MapFeature.State
    let send: (MapFeature.Action) -> Void
    
    let createToolbarItems: () -> [DWBottomToolbarItem]
    
    var body: some View {
        EmptyView()
            .sheet(item: activeSheetBinding) { sheet in
                buildSheet(sheet)
            }
            // TODO: Alert 창이 뒤에서 뜨는 부분 수정
            .dwAlert(
                isPresented: Binding(
                    get: { state.isDeleteAlertPresented },
                    set: { newValue in
                        if newValue == false {
                            send(.hideDeleteAlert)
                        }
                    }
                ),
                title: String(localized: .buttonDelete),
                message: String(localized: .pinDeleteAlertContent),
                primaryButton: DWAlertButton(
                    title: String(localized: .buttonDelete),
                    style: .destructive,
                    action: {
                        send(.confirmDeletePin)
                    }
                ),
                secondaryButton: DWAlertButton(
                    title: String(localized: .memoDeleteCancel),
                    style: .cancel,
                    action: {
                        send(.hideDeleteAlert)
                    }
                )
            )
    }
}

private extension MapSheetContainer {
    var activeSheetBinding: Binding<ActiveSheet?> {
        Binding(
            get: {
                if state.isPinWritePresented { return .pinWrite }
                if state.isMemoEditPresented { return .memoEdit }
                if state.isPlaceInfoSheetPresented { return .placeInfo }
                if state.isMapLayerSheetPresented { return .mapLayer }
                return nil
            },
            set: { newValue in
                if newValue == nil {
                    send(.closePinWrite)
                    send(.closeMemoEdit)
                    send(.hidePlaceInfo)
                    send(.setMapLayerSheetPresented(false))
                }
            }
        )
    }
    
    @ViewBuilder
    func buildSheet(_ sheet: ActiveSheet) -> some View {
        switch sheet {
        case .mapLayer:
            MapLayerSettingSheet(
                selectedRange: Binding(
                    get: { state.mapLayerCoverageRange },
                    set: { send(.setMapLayerCoverage($0)) }
                ),
                isCCTVEnabled: Binding(
                    get: { state.isCCTVLayerEnabled },
                    set: { send(.setCCTVLayerEnabled($0)) }
                ),
                isBaseStationEnabled: Binding(
                    get: { state.isBaseStationLayerEnabled },
                    set: { send(.setBaseStationLayerEnabled($0)) }
                ),
                onClose: { send(.setMapLayerSheetPresented(false)) }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
            
        case .placeInfo:
            if let placeInfo = state.selectedPlaceInfo {
                PlaceInfoSheet(
                    placeInfo: placeInfo,
                    existingLocation: state.existingLocation,
                    isLoading: state.isPlaceInfoLoading,
                    onClose: { send(.hidePlaceInfo) },
                    onMemoTapped: { send(.memoButtonTapped) }
                )
                .dwBottomToolBar(items: createToolbarItems())
                .presentationDetents([.fraction(state.hasExistingPin ? 0.5 : 0.4)])
                .presentationDragIndicator(.hidden)
            }
            
        case .pinWrite:
            if let placeInfo = state.selectedPlaceInfo,
               let caseId = state.caseId
            {
                PinWriteView(
                    placeInfo: placeInfo,
                    existingLocation: state.existingLocation,
                    caseId: caseId,
                    isEditMode: state.isEditMode,
                    onSave: { send(.savePin($0)) },
                    onCancel: { send(.closePinWrite) }
                )
                .presentationDetents([.height(630)])
                .presentationDragIndicator(.visible)
            }
            
        case .memoEdit:
            MemoWriteView(
                existingNote: state.existingLocation?.note,
                onSave: { note in send(.memoSaved(note)) },
                onCancel: { send(.closeMemoEdit) }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

enum ActiveSheet: Identifiable {
    case mapLayer
    case placeInfo
    case pinWrite
    case memoEdit
    
    var id: Int {
        switch self {
        case .mapLayer: 1
        case .placeInfo: 2
        case .pinWrite: 3
        case .memoEdit: 4
        }
    }
}
