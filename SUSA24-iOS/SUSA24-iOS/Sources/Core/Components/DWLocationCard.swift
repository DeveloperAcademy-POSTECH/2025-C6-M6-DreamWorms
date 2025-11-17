//
//  DWLocationCard.swift
//  SUSA24-iOS
//
//  Created by mini on 11/3/25.
//

import SwiftUI

// MARK: - LocationCard Type

/// `DWLocationCard`의 왼쪽 리드 아이콘(Leading Icon)의 형태를 정의합니다.
///
/// - `.icon(Image)`: 아이콘 이미지를 직접 전달하는 형태
/// - `.number(Int)`: 순서를 의미하는 숫자형 원형 배지 형태
enum DWLocationCardType: Equatable {
    case icon(Image)
    case number(Int)
}

// MARK: - View

/// 주소 정보를 가지고 아이콘 + 타이틀 + 설명으로 이어지는 공통의 카드 컴포넌트입니다.
///
/// **구성 요소**
/// - Leading Icon: 아이콘 또는 순번 원형 뱃지
/// - Title: 주요 텍스트 (예: 주소, 위치명)
/// - Description: 보조 텍스트 (예: 체류시간, 세부정보)
/// - Optional Arrow: 버튼형 카드일 경우 오른쪽 화살표 아이콘 표시
///
/// **특징**
/// - 버튼처럼 동작 가능 (`onTap`)
/// - 커스텀 가능한 아이콘 배경색 (`setupIconBackgroundColor`)
/// - 그림자 효과 포함
///
struct DWLocationCard: View {
    /// 카드의 타입 (아이콘 or 순번)
    let type: DWLocationCardType
    
    /// 카드의 타이틀 (주요 텍스트)
    let title: String
    
    /// 카드의 부제목 또는 설명 (보조 텍스트)
    let description: String
    
    /// 버튼 탭 시 실행되는 액션 (선택적)
    var onTap: (() -> Void)?
    
    /// 버튼 여부 (false일 경우 비활성화)
    var isButton: Bool = true
    
    /// 아이콘 배경색 (기본값: `.labelNeutral`)
    var iconBackgroundColor: Color = .labelNeutral
        
    var body: some View {
        Button(
            action: { onTap?() },
            label: {
                HStack(spacing: 12) {
                    // Leading Icon (왼쪽)
                    leadingIcon
                 
                    // Title & Description
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.titleSemiBold16)
                            .foregroundColor(.labelNormal)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                     
                        Text(description)
                            .font(.bodyRegular14)
                            .foregroundColor(.labelAlternative)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                 
                    // Trailing Arrow (버튼일 경우만 표시)
                    if isButton {
                        Image(.rightArrow)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.labelNeutral)
                    }
                }
                .padding([.vertical, .leading], 20)
                .padding(.trailing, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white)
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 12,
                            x: 0,
                            y: 2
                        )
                )
            }
        )
        .disabled(!isButton)
    }
    
    // MARK: - Leading Icon View Builder
    
    /// 카드의 왼쪽 리드 아이콘을 생성합니다.
    ///
    /// - `.icon(image)`: 지정한 이미지가 배경색 원 위에 표시됩니다.
    /// - `.number(num)`: 지정한 순서 번호가 원형 뱃지로 표시됩니다.
    @ViewBuilder
    private var leadingIcon: some View {
        switch type {
        case let .icon(image):
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 32, height: 32)
                .overlay {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
        case let .number(num):
            ZStack {
                Circle()
                    .fill(.primaryNormal)
                    .frame(width: 32, height: 32)
                Text("\(num + 1)")
                    .font(.numberSemiBold14)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension DWLocationCard {
    /// 해당 Card가 버튼처럼 동작하게 할 것인가의 여부를 지정합니다.
    /// - Parameter isButton: 버튼 여부
    @discardableResult
    func setupAsButton(_ isButton: Bool) -> Self {
        var v = self; v.isButton = isButton; return v
    }
    
    /// 왼쪽 아이콘의 배경색을 지정합니다.
    /// - Parameter color: 아이콘의 배경색
    @discardableResult
    func setupIconBackgroundColor(_ color: Color) -> Self {
        var v = self; v.iconBackgroundColor = color; return v
    }
    
    /// 카드 탭 시 실행될 액션을 설정합니다.
    /// - Parameter action: 탭 시 호출될 클로저
    @discardableResult
    func setupOnTap(_ action: (() -> Void)?) -> Self {
        var v = self; v.onTap = action; return v
    }
}

// MARK: - Preivew

// #Preview {
//    VStack {
//        DWLocationCard(
//            type: .number(1),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//
//        DWLocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//
//        DWLocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColor(PinColorType.red.color)
//
//        DWLocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColor(PinColorType.orange.color)
//
//        DWLocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColor(PinColorType.yellow.color)
//
//        DWLocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColor(PinColorType.lightGreen.color)
//
//        DWLocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColor(PinColorType.darkGreen.color)
//
//        DWLocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColor(PinColorType.purple.color)
//    }
//    .padding(.horizontal, 16)
// }
