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
    /// - NOTE: 인프라 레이어(cell, CCTV) 등 색 커스텀이 필요 없는 경우에만 사용합니다.
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

    // MARK: - User Location Helpers (PinColorType 기반)

    /// 사용자 홈 위치 마커 (색 커스텀)
    static func home(color: PinColorType) -> MarkerImage {
        MarkerImage.home(backgroundColor: color.color)
    }

    /// 사용자 직장 위치 마커 (색 커스텀)
    static func work(color: PinColorType) -> MarkerImage {
        MarkerImage.work(backgroundColor: color.color)
    }

    /// 사용자 커스텀 위치 마커 (색 커스텀)
    static func custom(color: PinColorType) -> MarkerImage {
        MarkerImage.custom(backgroundColor: color.color)
    }
}

// MARK: - Selected Pin (Large Pin) Support

/// 선택된 위치를 나타내는 큰 핀 스타일
enum SelectedPinStyle: Hashable, Sendable {
    case home(PinColorType)
    case work(PinColorType)
    case custom(PinColorType)
    case cell(PinColorType)
    
    /// 캐시 키용 문자열
    var cacheKey: String {
        switch self {
        case let .home(color): "selected_home_\(color.rawValue)"
        case let .work(color): "selected_work_\(color.rawValue)"
        case let .custom(color): "selected_custom_\(color.rawValue)"
        case let .cell(color): "selected_cell_\(color.rawValue)"
        }
    }
    
    /// 핀 색상
    var pinColor: PinColorType {
        switch self {
        case let .home(color),
             let .work(color),
             let .custom(color),
             let .cell(color):
            color
        }
    }
    
    /// 핀 내부에 들어갈 아이콘
    var icon: Image {
        switch self {
        case .home:
            Image(.icnHome)
        case .work:
            Image(.icnWork)
        case .custom:
            Image(.icnPin)
        case .cell:
            Image(.icnCellStationFilter)
        }
    }
}

/// 선택된 위치를 나타내는 큰 핀 이미지
struct SelectedPinImage: View {
    let style: SelectedPinStyle
    
    /// 전체 핀 크기 (32x42), 아이콘 크기는 22x22
    private let pinSize = CGSize(width: 32, height: 42)
    private let iconSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            Image(.pinShape)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(style.pinColor.color)
                .frame(width: pinSize.width, height: pinSize.height)
            
            // 내부 아이콘 (항상 흰색)
            style.icon
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: iconSize, height: iconSize)
                .padding(.bottom, 12)
        }
        .frame(width: pinSize.width, height: pinSize.height)
    }
}

// MARK: - Selected Pin Preview

//#Preview("Selected Pins") {
//    VStack(spacing: 16) {
//        HStack(spacing: 16) {
//            SelectedPinImage(style: .home(.black))
//            SelectedPinImage(style: .home(.yellow))
//            SelectedPinImage(style: .home(.red))
//        }
//        HStack(spacing: 16) {
//            SelectedPinImage(style: .work(.black))
//            SelectedPinImage(style: .custom(.orange))
//            SelectedPinImage(style: .cell(.darkGreen))
//        }
//    }
//    .padding()
//    .background(Color.gray.opacity(0.2))
//}

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
