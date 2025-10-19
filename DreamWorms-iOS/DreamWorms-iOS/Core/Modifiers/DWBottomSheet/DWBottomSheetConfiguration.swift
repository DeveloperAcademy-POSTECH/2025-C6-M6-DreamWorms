//
//  DWBottomSheetConfiguration.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

// MARK: - BottomSheet Configuration

/// 바텀시트 설정 관리
///
/// 역할: 바텀시트 동작 규칙만 정의

enum DWBottomSheetConfiguration {
    // MARK: - Detents
    
    /// 지원하는 Detent 목록
    static let supportedDetents: Set<PresentationDetent> = [
        .small,
        .medium,
        .large
    ]
    
    // MARK: - Interaction
    
    /// 배경 상호작용 허용 범위
    ///
    /// Small / Medium: 지도 터치 가능
    /// Large: 지도 터치 불가
    static let backgroundInteraction: PresentationBackgroundInteraction = .enabled(upThrough: .medium)
    
    // MARK: - Appearance
    
    /// 모서리 둥글기 반경
    static let defaultCornerRadius: CGFloat = 16
    
    /// 드래그 인디케이터 표시 여부
    ///
    /// - Parameters
    ///         - detent: 현재 Detent 상태
    ///         - return: true면 표시, false면 숨김
    static func shouldShowDragIndicator(for detent: PresentationDetent) -> Bool {
        detent != .large
    }
}
