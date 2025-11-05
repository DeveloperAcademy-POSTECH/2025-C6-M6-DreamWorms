//
//  TimeLineColorStick.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/4/25.
//

import SwiftUI

//MARK: - State

/// 'TimeLineColorStack'의 상태를 정의합니다.
///
/// 방문 빈도에 따른 시각적 강조를 위해 사용됩니다.
/// - 'top1', 'top2', 'top3', 'normal' 네가지 상태를 가집니다.
/// - 색상 및 드랍 섀도우 효과는 블러 4 정도로 동일하게 유지됩니다.

enum TimeLineColorStickState: Equatable {
    case top1
    case top2
    case top3
    case normal
    
    var spotColor: Color {
        switch self {
        case .top1: .blue40
        case .top2: .blue50
        case .top3: .blue60
        case .normal: .blue80
        }
    }
}

//MARK: - View

/// 타임라인 셀 내에서 사용되는 막대(Bar) 컴포넌트
///
/// 방문 빈도( top1~3 / normal)에 따라 spotColor가 다릅니다.
/// - 드랍 섀도우: 모든 상태에서 동일하게 적용 ( blur = 4 )
/// - 도트(Circle)과 수직막대(Rectangle)로 구성
/// - 마지막 셀일때는 막대가 표시되지 않음
///
/// # 사용예시
/// ```swift
/// // 일반셀
/// TimeLineColorStick(state: .top1, isLast: false)
///
/// // 마지막 셀 (막대 숨김)
/// TimeLineColorStick(state: .top1, isLast: true)
/// ```
///
struct TimeLineColorStick: View {
    
    let state: TimeLineColorStickState
    let isLast: Bool
    
    var contentPadding: EdgeInsets = .init(top: 10, leading: 10, bottom: 7, trailing: 10)
    var stickHeight: CGFloat = 41
    var spotColor: TimeLineColorStickState = .normal
    
    private let shadowOpacity: Double = 1.0
    private let shadowRadius: CGFloat = 4
    
    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(state.spotColor)
                .frame(width: 7, height: 7)
                .shadow(color: state.spotColor.opacity(shadowOpacity),
                        radius: shadowRadius,
                        x: 0,
                        y: 0
                )
                .padding(contentPadding)
            
            Rectangle()
                .fill(isLast ? .clear : .blue80)
                .frame(width: 1, height: stickHeight)
        }
        .animation(.snappy(duration: 0.2), value: state)
    }
}

//MARK: - Progressive Disclosure
extension TimeLineColorStick {
    
    /// 막대 높이를 설정합니다.
    ///
    /// - Parameter value: 막대의 세로 길이 (기본값: 80)
    @discardableResult
    func setupHeight(_ value: CGFloat) -> Self {
        var v = self
        v.stickHeight = value
        return v
    }
    
    /// 스팟 색상을 커스텀합니다.
    ///
    /// - Parameter value: 막대의 세로 길이 (기본값: 80)
    @discardableResult
    func setupSpotColor(_ value: TimeLineColorStickState) -> Self {
        var v = self
        v.spotColor = value
        return v
    }
}

// MARK: - Preview
//
//#Preview("Timeline Bar - States") {
//    HStack(spacing: 24) {
//        TimeLineColorStick(state: .top1)
//        TimeLineColorStick(state: .top2)
//        TimeLineColorStick(state: .top3)
//        TimeLineColorStick(state: .normal)
//    }
//    .padding()
//    .background(.testBackground)
//}
