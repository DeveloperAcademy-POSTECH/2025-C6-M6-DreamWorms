//
//  MarkerImage.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/11/25.
//

import SwiftUI

// MARK: - Marker

/// 지도에 표시할 마커 컴포넌트
/// - 기본 20x20 크기의 원형 마커 (CCTV는 18x18)
/// - 테두리, 내부 색상, 아이콘 색상, 크기 커스터마이징 가능
struct MarkerImage: View {
    // MARK: - Properties
    
    /// 아이콘 이미지 (숫자 배지 사용 시 nil 가능)
    let icon: Image?
    
    /// 테두리 색상
    let borderColor: Color
    
    /// 내부 배경 색상
    let backgroundColor: Color
    
    /// 아이콘 색상
    let iconColor: Color
    
    /// 아이콘 크기 (기본값: 10x10)
    let iconSize: CGFloat
    
    /// 전체 핀 크기 (기본값: 20x20)
    let size: CGFloat
    
    /// 테두리 두께 (기본값: 1pt)
    let borderWidth: CGFloat
    
    /// 중앙에 표시할 숫자 텍스트 (방문횟수 등)
    let badgeText: String?
    
    /// 배지 텍스트 색상
    let badgeTextColor: Color
    
    // MARK: - Initializer
    
    /// 커스텀 스타일로 마커를 생성합니다.
    init(
        icon: Image? = nil,
        borderColor: Color = .white,
        backgroundColor: Color,
        iconColor: Color = .white,
        iconSize: CGFloat = 10,
        size: CGFloat = 20,
        borderWidth: CGFloat = 1,
        badgeText: String? = nil,
        badgeTextColor: Color = .white
    ) {
        self.icon = icon
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.iconSize = iconSize
        self.size = size
        self.borderWidth = borderWidth
        self.badgeText = badgeText
        self.badgeTextColor = badgeTextColor
    }
    
    /// 타입에 따라 기본 스타일로 마커를 생성합니다.
    init(type: MarkerType) {
        let marker: MarkerImage = switch type {
        case .home:
            MarkerImage.home()
        case .work:
            MarkerImage.work()
        case let .cell(isVisited):
            isVisited ? MarkerImage.visitedCell() : MarkerImage.cell()
        case let .cellWithCount(count):
            MarkerImage.cellWithCount(count)
        case .cctv:
            MarkerImage.cctv()
        case .custom:
            MarkerImage.custom()
        }
        
        self.icon = marker.icon
        self.borderColor = marker.borderColor
        self.backgroundColor = marker.backgroundColor
        self.iconColor = marker.iconColor
        self.iconSize = marker.iconSize
        self.size = marker.size
        self.borderWidth = marker.borderWidth
        self.badgeText = marker.badgeText
        self.badgeTextColor = marker.badgeTextColor
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 테두리 (외부 원)
            Circle()
                .fill(borderColor)
                .frame(width: size, height: size)
            
            // 내부 배경
            Circle()
                .fill(backgroundColor)
                .frame(width: size - borderWidth * 2, height: size - borderWidth * 2)
            
            // 아이콘 또는 배지 텍스트
            if let badgeText {
                // 숫자 배지
                Text(badgeText)
                    .font(.numberSemiBold9)
                    .foregroundStyle(badgeTextColor)
            } else if let icon {
                // 아이콘
                icon
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(iconColor)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Convenience Initializers

extension MarkerImage {
    /// 홈 마커 (기본 스타일)
    static func home(
        borderColor: Color = .white,
        backgroundColor: Color = .pointPurple,
        iconColor: Color = .white
    ) -> MarkerImage {
        MarkerImage(
            icon: Image(.icnHome),
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            iconColor: iconColor
        )
    }
    
    /// 직장 마커 (기본 스타일)
    static func work(
        borderColor: Color = .white,
        backgroundColor: Color = .gray20,
        iconColor: Color = .white
    ) -> MarkerImage {
        MarkerImage(
            icon: Image(.icnWork),
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            iconColor: iconColor
        )
    }
    
    /// 기지국 마커 (기본 기지국)
    static func cell(
        borderColor: Color = .white,
        backgroundColor: Color = .labelAlternative,
        iconColor: Color = .white
    ) -> MarkerImage {
        MarkerImage(
            icon: Image(.icnCellStationFilter),
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            iconColor: iconColor
        )
    }
    
    /// 기지국 마커 (방문 완료)
    static func visitedCell(
        borderColor: Color = .white,
        backgroundColor: Color = .primaryNormal,
        iconColor: Color = .white
    ) -> MarkerImage {
        MarkerImage(
            icon: Image(.icnCellStationFilter),
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            iconColor: iconColor
        )
    }
    
    /// 방문횟수 표시 기지국 마커 (22x22 크기, 숫자 표시)
    static func cellWithCount(
        _ count: Int,
        borderColor: Color = .white,
        backgroundColor: Color = .primaryNormal,
        badgeTextColor: Color = .white
    ) -> MarkerImage {
        MarkerImage(
            icon: nil, // 아이콘 없이 숫자만 표시
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            size: 22,
            borderWidth: 1,
            badgeText: "\(count)",
            badgeTextColor: badgeTextColor
        )
    }
    
    /// CCTV 마커 (18x18 크기)
    static func cctv(
        borderColor _: Color = .labelAlternative,
        backgroundColor: Color = .labelCoolNormal,
        iconColor _: Color = .labelAlternative
    ) -> MarkerImage {
        MarkerImage(
            icon: Image(.icnCctv),
            borderColor: .labelAlternative,
            backgroundColor: backgroundColor,
            iconColor: .labelAlternative,
            iconSize: 12,
            size: 18,
            borderWidth: 1
        )
    }

    /// 커스텀 장소 마커 (기본 스타일)
    static func custom(
        borderColor: Color = .white,
        backgroundColor: Color = .pointRed2,
        iconColor: Color = .white
    ) -> MarkerImage {
        MarkerImage(
            icon: Image(.icnPin),
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            iconColor: iconColor
        )
    }
}

// MARK: - Preview

// #Preview("기본 마커 - Static 메서드") {
//    VStack {
//        HStack {
//            MarkerImage.home()
//            MarkerImage.work()
//            MarkerImage.cell()
//            MarkerImage.visitedCell()
//        }
//
//        HStack {
//            MarkerImage.visitedCell()
//            MarkerImage.cellWithCount(5)
//            MarkerImage.cellWithCount(50)
//            MarkerImage.custom()
//            MarkerImage.cctv()
//        }
//    }
//    .padding()
//    .background(.gray)
// }
