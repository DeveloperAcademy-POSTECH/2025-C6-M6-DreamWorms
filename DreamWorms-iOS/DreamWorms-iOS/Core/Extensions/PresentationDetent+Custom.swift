//
//  PresentationDetent+Custom.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

// MARK: - Custom PresentationDetent

extension PresentationDetent {
    /// Small - 헤더만 표시 ( 화면의 20% )
    ///
    /// 사용자가 지도를 보면서 최소한의 정보만 확인할 수 있도록 합니다.
    /// 주요 정보( 기지국, 카드내역, 차량정보, 범행장소 )만 표시합니다.
    ///
    /// Reference: [Apple HIG - Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
    static let small = Self.fraction(0.2)
    
    /// Medium - 헤더 + 탭 + 리스트 일부 (화면의 50%)
    ///
    /// 중요한 콘텐츠를 미리 보여주며 사용자가 더 보기를 원하도록 유도합니다.
    /// 헤더, 탭바, 날짜 지정, 리스트 일부( 2개 정도 )를 보여줍니다.
    ///
    /// - Reference: [Apple HIG - Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
    static let medium = Self.fraction(0.5)
        
    /// Large - 전체 화면 (화면의 100%)
    ///
    /// 바텀시트의 모든 콘텐츠를 확장하여 전체 리스트를 보여줍니다.
    /// 왼쪽 위 닫기(X) 버튼으로 Medium으로 돌아갈 수 있습니다.
    ///
    /// - Note: safe area 포함 전체 화면
    static let large = Self.fraction(1.0)
}
