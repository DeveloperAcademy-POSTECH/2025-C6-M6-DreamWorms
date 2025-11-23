//
//  NMConstants.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

import CoreLocation
import UIKit

/// 맵 관련 모든 상수를 관리하는 열거형
enum MapConstants {
    // MARK: - CCTV 관련 constans
    
    /// CCTV 조회를 위한 최소 줌 레벨
    static let minZoomForCCTV: Double = 10.0
    /// CCTV 기본 조회 크기
    static let defaultCCTVFetchSize: Int = 1000
    /// CCTV 최대 캐시 개수
    static let maxCachedCCTVCount: Int = 3000
    
    // MARK: - 지도 관련 constants
    
    /// 기본 줌 레벨
    static let defaultZoomLevel: Double = 15.0
    /// 마커 표시 임계값 (이 값보다 큰 줌 레벨에서 마커 표시)
    static let markerVisibilityThreshold: Double = 8

    // MARK: - Animation
    
    /// 카메라 이동 애니메이션 지속 시간 (초)
    static let cameraAnimationDuration: Double = 0.7
    
    // MARK: - Location
    
    /// 위치 정확도 (100미터)
    static let locationAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    
    // MARK: - Colors
    
    /// 기지국 범위 오버레이 색상 (RGBA: 55, 110, 228, 0.2)
    static let cellRangeOverlayColor: UIColor = UIColor(
        red: 55 / 255,
        green: 110 / 255,
        blue: 228 / 255,
        alpha: 0.08
    )
    
    // MARK: - Content Inset
    
    /// 바텀시트가 330이고 헤더가 간단하게 계산해봤을 때 120임.
    /// 총 높이 800 - 330 - 120 = 340이고, 가운데 높이는 170. 고로 170으로 설정.
    static let timelineSheetBottomInset: CGFloat = 170.0
}
