//
//  LocationCard.swift
//  SUSA24-iOS
//
//  Created by mini on 11/3/25.
//

import SwiftUI

// MARK: - LocationCard Type

enum LocationCardType: Equatable {
    case icon(Image)
    case number(Int)
}

// MARK: - Pin Color Type

enum PinColorType: Int {
    case black
    case red
    case orange
    case yellow
    case lightGreen
    case darkGreen
    case purple
    
    var color: Color {
        switch self {
        case .black: Color.labelNeutral
        case .red: Color.pointRed2
        case .orange: Color.pinOrange
        case .yellow: Color.pinYellow
        case .lightGreen: Color.pinLightGreen
        case .darkGreen: Color.pinDarkGreen
        case .purple: Color.pointPurple
        }
    }
}

// MARK: - View

struct LocationCard: View {
    let type: LocationCardType
    let title: String
    let description: String
    let onTap: (() -> Void)? = nil
    
    var isButton: Bool = true
    var iconBackgroundColor: PinColorType = .black
        
    var body: some View {
        Button(
            action: { onTap?() },
            label: {
             HStack(spacing: 12) {
                 leadingIcon
                 
                 VStack(alignment: .leading, spacing: 0) {
                     Text(title)
                         .font(.titleSemiBold16)
                         .foregroundColor(.labelNormal)
                     
                     Text(description)
                         .font(.bodyRegular14)
                         .foregroundColor(.labelAlternative)
                 }
                 .frame(maxWidth: .infinity, alignment: .leading)
                 
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
         })
         .disabled(!isButton)
    }
    
    // MARK: - Leading Icon View Builder
    
    @ViewBuilder
    private var leadingIcon: some View {
        switch type {
        case .icon(let image):
            Circle()
                .fill(iconBackgroundColor.color)
                .frame(width: 32, height: 32)
                .overlay {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
        case .number(let num):
            ZStack {
                Circle()
                    .fill(.primaryNormal)
                    .frame(width: 32, height: 32)
                Text("\(num+1)")
                    .font(.numberSemiBold14)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension LocationCard {
    
    /// 해당 Card가 버튼처럼 동작하게 할 것인가의 여부를 지정합니다.
    /// - Parameter isButton: 버튼 여부
    @discardableResult
    func setupAsButton(_ isButton: Bool) -> Self {
        var v = self; v.isButton = isButton; return v
    }
    
    /// 왼쪽 아이콘의 배경색을 지정합니다.
    /// - Parameter color: 아이콘의 배경색
    @discardableResult
    func setupIconBackgroundColorType(_ colorType: PinColorType) -> Self {
        var v = self; v.iconBackgroundColor = colorType; return v
    }
}

// MARK: - Preivew

//#Preview {
//    VStack {
//        LocationCard(
//            type: .number(1),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        
//        LocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        
//        LocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColorType(.red)
//        
//        LocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColorType(.orange)
//        
//        LocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColorType(.yellow)
//        
//        LocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColorType(.lightGreen)
//        
//        LocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColorType(.darkGreen)
//        
//        LocationCard(
//            type: .icon(Image(.icnPin)),
//            title: "기지국 주소",
//            description: "19시간 체류",
//            isButton: true
//        )
//        .setupAsButton(false)
//        .setupIconBackgroundColorType(.purple)
//    }
//    .padding(.horizontal, 16)
//}
