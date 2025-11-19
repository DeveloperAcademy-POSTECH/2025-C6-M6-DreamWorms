//
//  MapLayerUpdater.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/25/25.
//

import Foundation
import NMapsMap

/// 맵 레이어 업데이트를 담당하는 업데이터
/// - 모든 레이어(Cell, CCTV, CaseLocation, CellRange) 업데이트를 중앙에서 관리
/// - 해시 기반 변경 감지 로직 통합
/// - 레이어별 가시성 상태 추적 및 적용
@MainActor
final class MapLayerUpdater {
    // MARK: - Dependencies
    
    private let infrastructureManager: InfrastructureMarkerManager
    private let caseLocationMarkerManager: CaseLocationMarkerManager
    
    // MARK: - Change Detection State
    
    private var lastCellStationsHash: Int?
    private var lastLocationsHash: Int?
    private var lastCellRangeConfig: CellRangeConfig?
    private var lastCCTVMarkersHash: Int?
    private var lastCellMarkerVisibility: Bool?
    private var lastCCTVVisibility: Bool?
    
    // MARK: - Callbacks
    
    /// 기지국 셀 마커 탭 이벤트 콜백
    var onCellMarkerTapped: ((String, String?) -> Void)?
    
    /// 사용자 위치 마커 탭 이벤트 콜백
    var onUserLocationMarkerTapped: ((UUID) -> Void)?
    
    // MARK: - Initialization
    
    init(
        infrastructureManager: InfrastructureMarkerManager,
        caseLocationMarkerManager: CaseLocationMarkerManager
    ) {
        self.infrastructureManager = infrastructureManager
        self.caseLocationMarkerManager = caseLocationMarkerManager
    }
    
    // MARK: - Layer Update Methods
    
    /// CaseLocation 마커를 업데이트합니다.
    /// - Parameters:
    ///   - locations: 위치 데이터 배열
    ///   - visitFrequencyEnabled: 방문 빈도 활성화 여부
    ///   - isVisible: 마커 가시성
    ///   - zoomLevel: 현재 줌 레벨
    ///   - mapView: 네이버 지도 뷰
    func updateCaseLocations(
        locations: [Location],
        visitFrequencyEnabled: Bool,
        isVisible: Bool,
        zoomLevel: Double,
        on mapView: NMFMapView
    ) {
        let newHash = MapDataService.hash(for: locations, visitFrequencyEnabled: visitFrequencyEnabled)
        
        let shouldUpdate = lastLocationsHash != newHash
        
        if shouldUpdate {
            Task { @MainActor in
                let cellCounts = await caseLocationMarkerManager.updateMarkers(
                    locations,
                    on: mapView,
                    onCellTapped: { [weak self] cellKey in
                        guard let self else { return }
                        Task { @MainActor in
                            // title은 Coordinator의 콜백에서 찾아서 전달
                            onCellMarkerTapped?(cellKey, nil)
                        }
                    },
                    onUserLocationTapped: { [weak self] locationId in
                        guard let self else { return }
                        onUserLocationMarkerTapped?(locationId)
                    }
                )
                
                if visitFrequencyEnabled {
                    await caseLocationMarkerManager.applyVisitFrequency(with: cellCounts, on: mapView)
                } else {
                    await caseLocationMarkerManager.resetVisitFrequency(on: mapView)
                }
                
                // 마커 업데이트 완료 후 가시성 재적용
                caseLocationMarkerManager.setVisibility(isVisible)
                // 줌 레벨에 따른 캡션 가시성 업데이트
                caseLocationMarkerManager.updateCaptionVisibility(locations: locations, zoomLevel: zoomLevel)
            }
            
            lastLocationsHash = newHash
        } else {
            // 해시가 같아도 가시성은 다시 적용 (줌 레벨 변경 시)
            caseLocationMarkerManager.setVisibility(isVisible)
            // 줌 레벨에 따른 캡션 가시성 업데이트
            caseLocationMarkerManager.updateCaptionVisibility(locations: locations, zoomLevel: zoomLevel)
        }
    }
    
    /// 기지국 셀 레이어를 업데이트합니다.
    /// - Parameters:
    ///   - cellMarkers: 기지국 셀 마커 배열
    ///   - isVisible: 마커 가시성
    ///   - mapView: 네이버 지도 뷰
    func updateCellLayer(
        cellMarkers: [CellMarker],
        isVisible: Bool,
        on mapView: NMFMapView
    ) {
        let newHash = cellMarkers.map(\.id).hashValue
        
        if lastCellStationsHash != newHash {
            infrastructureManager.updateCellStations(
                cellMarkers,
                on: mapView,
                isVisible: isVisible
            )
            lastCellStationsHash = newHash
        } else {
            infrastructureManager.setCellVisibility(isVisible)
        }
    }
    
    /// 기지국 범위 오버레이를 업데이트합니다.
    /// - Parameters:
    ///   - cellMarkers: 기지국 셀 마커 배열
    ///   - coverageRange: 커버리지 범위 타입
    ///   - isVisible: 오버레이 가시성
    ///   - mapView: 네이버 지도 뷰
    func updateCellRangeOverlay(
        cellMarkers: [CellMarker],
        coverageRange: CoverageRangeType,
        isVisible: Bool,
        on mapView: NMFMapView
    ) {
        let config = CellRangeConfig(
            markerHash: MapDataService.hash(for: cellMarkers),
            coverageRange: coverageRange,
            isVisible: isVisible
        )
        
        guard config != lastCellRangeConfig else { return }
        lastCellRangeConfig = config
        
        Task { [infrastructureManager] in
            await infrastructureManager.updateCellRanges(
                cellMarkers,
                coverageRange: coverageRange,
                isVisible: isVisible,
                on: mapView
            )
        }
    }
    
    /// CCTV 레이어를 업데이트합니다.
    /// - Parameters:
    ///   - cctvMarkers: CCTV 마커 배열
    ///   - isVisible: 마커 가시성
    ///   - mapView: 네이버 지도 뷰
    func updateCCTVLayer(
        cctvMarkers: [CCTVMarker],
        isVisible: Bool,
        on mapView: NMFMapView
    ) {
        let newHash = cctvMarkers.map(\.id).hashValue
        
        if lastCCTVMarkersHash != newHash {
            infrastructureManager.updateCCTVs(
                cctvMarkers,
                on: mapView,
                isVisible: isVisible
            )
            lastCCTVMarkersHash = newHash
        } else {
            infrastructureManager.setCCTVVisibility(isVisible)
        }
    }
    
    /// 마커 가시성 상태를 추적하고 네이버 지도 오버레이에 적용합니다.
    /// CaseLocation 마커는 updateCaseLocations에서 이미 처리되므로 여기서는 CellMarker와 CCTV만 처리합니다.
    /// - Parameters:
    ///   - isCaseLocationVisible: CaseLocation 마커 가시성 (사용하지 않음, updateCaseLocations에서 처리)
    ///   - isCellMarkerVisible: Cell 마커 가시성
    ///   - isCCTVVisible: CCTV 마커 가시성
    func updateMarkerVisibility(
        isCaseLocationVisible _: Bool,
        isCellMarkerVisible: Bool,
        isCCTVVisible: Bool
    ) {
        // CaseLocation은 updateCaseLocations에서 이미 처리됨
        
        if lastCellMarkerVisibility != isCellMarkerVisible {
            lastCellMarkerVisibility = isCellMarkerVisible
            infrastructureManager.setCellVisibility(isCellMarkerVisible)
        }
        
        if lastCCTVVisibility != isCCTVVisible {
            lastCCTVVisibility = isCCTVVisible
            infrastructureManager.setCCTVVisibility(isCCTVVisible)
        }
    }
    
    // MARK: - Private Types
    
    private struct CellRangeConfig: Equatable {
        let markerHash: Int
        let coverageRange: CoverageRangeType
        let isVisible: Bool
    }
}
