//
//  MapHeader.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// 지도 화면의 상단 헤더 컴포넌트
///
/// 뒤로 가기 버튼과 검색 바를 포함하는 헤더입니다.
struct MapHeader: View {
    /// 뒤로 가기 버튼을 탭했을 때 실행되는 액션입니다.
    let onBackTapped: () -> Void
    /// 검색 바를 탭했을 때 실행되는 액션입니다.
    let onSearchTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            DWGlassEffectCircleButton(
                action: onBackTapped,
                icon: Image(.back)
            )
            .setupSize(44)
            .setupIconSize(18)

            DWSearchBar(isTapped: onSearchTapped)
        }
    }
}

//#Preview {
//    MapHeader(
//        onBackTapped: {},
//        onSearchTapped: {}
//    )
//    .padding()
//}
