//
//  MapSheetPanel.swift
//  SUSA24-iOS
//
//  Created by mini on 11/20/25.
//

import SwiftUI

struct MapSheetPanel: View {
    let state: MapFeature.State
    let send: (MapFeature.Action) -> Void
    
    @State private var isAlertPresented = false
    
    var body: some View {
        Group {
            if state.isMapLayerSheetPresented {
                mapLayerPanel
            } else if state.isPlaceInfoSheetPresented {
                placeInfoPanel
            } else if state.isPinWritePresented {
                pinWritePanel
            } else if state.isMemoEditPresented {
                memoEditPanel
            } else {
                EmptyView()
            }
        }
        .alert(
            String(localized: .buttonDelete),
            isPresented: $isAlertPresented
        ) {
            Button(String(localized: .buttonDelete), role: .destructive) {
                send(.confirmDeletePin)
            }
            Button(String(localized: .cancelDefault), role: .cancel) {}
        } message: {
            Text(String(localized: .pinDeleteAlertContent))
        }
    }
}

private extension MapSheetPanel {
    var mapLayerPanel: some View {
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
    }
    
    var placeInfoPanel: some View {
        Group {
            if let placeInfo = state.selectedPlaceInfo {
                PlaceInfoSheet(
                    placeInfo: placeInfo,
                    existingLocation: state.existingLocation,
                    isLoading: state.isPlaceInfoLoading,
                    onClose: { send(.hidePlaceInfo()) },
                    onMemoTapped: { send(.memoButtonTapped) }
                )
                .dwBottomToolBar(items: createToolbarItems())
            }
        }
    }
    
    var pinWritePanel: some View {
        Group {
            if let placeInfo = state.selectedPlaceInfo,
               let caseId = state.caseId
            {
                PinWriteView(
                    placeInfo: placeInfo,
                    coordinate: state.selectedCoordinate,
                    existingLocation: state.existingLocation,
                    caseId: caseId,
                    isEditMode: state.isEditMode,
                    onSave: { send(.savePin($0)) },
                    onCancel: { send(.closePinWrite) }
                )
            }
        }
    }
    
    var memoEditPanel: some View {
        MemoWriteView(
            existingNote: state.existingLocation?.note,
            onSave: { note in send(.memoSaved(note)) },
            onCancel: { send(.closeMemoEdit) }
        )
    }
    
    /// MapSheetPanel 하단 툴바 아이템 생성
    func createToolbarItems() -> [DWBottomToolbarItem] {
        if state.hasExistingPin {
            [
                .button(image: Image(.pinFill), action: {}),
                .menu(
                    image: Image(.ellipsis),
                    items: [
                        .init(
                            title: String(localized: .buttonEdit),
                            systemImage: SymbolLiterals.edit.rawValue,
                            role: nil,
                            action: { send(.editPinTapped) }
                        ),
                        .init(
                            title: String(localized: .buttonDelete),
                            systemImage: SymbolLiterals.delete.rawValue,
                            role: .destructive,
                            action: { isAlertPresented = true }
                        ),
                    ]
                ),
            ]
        } else {
            [
                .button(
                    image: Image(.pin),
                    action: { send(.addPinTapped) }
                ),
            ]
        }
    }
}

// #Preview {
//    MapSheetPanel()
// }
