//
//  MapCameraController.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/25/25.
//

import Foundation
import NMapsMap
import UIKit

/// 맵 카메라 제어를 담당하는 컨트롤러
@MainActor
final class MapCameraController {
    // MARK: - Properties
    
    /// 네이버 지도 뷰 인스턴스에 대한 약한 참조 (Coordinator의 mapView와 동일한 인스턴스)
    /// - Note: `updateUIView`에서 Coordinator의 mapView와 동일한 인스턴스를 할당합니다.
    weak var mapView: NMFMapView?
    
    /// 기본 줌 레벨
    var defaultZoomLevel: Double = MapConstants.defaultZoomLevel
    
    /// 마지막 카메라 이동 목표 좌표 (중복 이동 방지용)
    var lastCameraTarget: MapCoordinate?
    
    /// 카메라 이동 완료 콜백
    var onCameraIdle: ((MapBounds, Double) -> Void)?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Camera Control
    
    /// 전달받은 좌표로 네이버 지도 카메라를 이동시킵니다.
    /// - Parameters:
    ///   - coordinate: 이동할 지도 좌표
    ///   - animated: 애니메이션 적용 여부. nil이면 애니메이션을 적용하지 않습니다.
    ///   - duration: 애니메이션 지속 시간 (초). animated가 true일 때만 유효합니다.
    func moveCamera(to coordinate: MapCoordinate, animated: Bool? = nil, duration: Double? = nil) {
        guard let mapView else { return }
        let target = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(target, zoom: defaultZoomLevel))
        if let animated, animated, let duration {
            cameraUpdate.animation = .easeOut
            cameraUpdate.animationDuration = duration
        } else { cameraUpdate.animation = .none }
        mapView.moveCamera(cameraUpdate)
    }
    
    /// 카메라 이동이 완료되었을 때 호출되는 메서드입니다.
    /// - Parameter mapView: 네이버 지도 뷰
    func handleCameraIdle(_ mapView: NMFMapView) {
        guard let bounds = MapBounds(naverBounds: mapView.contentBounds) else { return }
        let zoomLevel = mapView.zoomLevel
        Task { @MainActor in
            onCameraIdle?(bounds, zoomLevel)
        }
    }
    
    /// 카메라 이동 명령을 처리합니다.
    /// - Parameters:
    ///   - coordinate: 이동할 좌표 (nil이면 목표 좌표 초기화)
    ///   - shouldAnimate: 애니메이션 적용 여부
    ///   - onConsumed: 명령 소비 콜백
    /// - Returns: 카메라 이동이 수행되었는지 여부
    @discardableResult
    func processCameraTarget(coordinate: MapCoordinate?, shouldAnimate: Bool, onConsumed: (() -> Void)?) -> Bool {
        if let coordinate, lastCameraTarget != coordinate {
            lastCameraTarget = coordinate
            if shouldAnimate { moveCamera(to: coordinate, animated: true, duration: MapConstants.cameraAnimationDuration) }
            else { moveCamera(to: coordinate) }
            Task { @MainActor in
                onConsumed?()
            }
            return true
        } else if coordinate == nil { lastCameraTarget = nil }
        return false
    }
    
    // MARK: - Content Inset
    
    /// 지도 콘텐츠 패딩을 설정합니다.
    /// UI 요소(시트, 핀 등)가 지도의 일부를 덮을 경우, 카메라 위치를 실제 보이는 지도 중심에 맞추기 위해 사용합니다.
    /// - Parameter inset: 콘텐츠 패딩 (top, left, bottom, right)
    func setContentInset(_ inset: UIEdgeInsets) {
        guard let mapView else { return }
        mapView.contentInset = inset
    }
    
    /// 시트 상태에 따라 콘텐츠 패딩을 설정합니다.
    /// - Parameters:
    ///   - isTimelineSheetPresented: 타임라인 시트가 표시되어 있는지 여부
    ///   - isPlaceInfoSheetPresented: PlaceInfoSheet가 표시되어 있는지 여부
    func updateContentInsetForSheet(isTimelineSheetPresented: Bool, isPlaceInfoSheetPresented: Bool) {
        let isMinimized = !isTimelineSheetPresented && !isPlaceInfoSheetPresented
        
        if isMinimized { setContentInset(.zero) }
        else {
            let inset = UIEdgeInsets(top: 0, left: 0, bottom: MapConstants.timelineSheetBottomInset, right: 0)
            setContentInset(inset)
        }
    }
}
