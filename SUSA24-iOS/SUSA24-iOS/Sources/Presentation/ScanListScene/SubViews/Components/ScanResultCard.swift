//
//  ScanResultCard.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

// MARK: - View

// 스캔된 주소 컴포넌트 카드
struct ScanResultCard: View {
    // MARK: - Properties

    let address: String
    let duplicateCount: Int
    let isSelected: Bool
    let selectedCategory: PinCategoryType?
    let onToggleSelection: () -> Void
    let onCategorySelect: (PinCategoryType) -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(address)
                        .font(.bodyMedium16)
                        .foregroundStyle(.labelNormal)
                        .lineLimit(2)
                    Text(.scanListCardCount(duplicateCount))
                        .font(.captionRegular12)
                        .foregroundStyle(.labelAlternative)
                }

                Spacer()

                Button(action: onToggleSelection) {
                    Image(.checkmarkFill)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .primaryNormal : .labelAssistive)
                }
                .buttonStyle(.borderless)
            }.padding(.top, 14)
                .padding(.bottom, 12)

            if isSelected {
                VStack(spacing: 8) {
                    Divider()
                        .background(.labelCoolNormal)
                        .padding(.bottom, 2)

                    HStack(spacing: 12) {
                        ForEach(PinCategoryType.allCases, id: \.self) { type in
                            let isSelectedPin = (selectedCategory ?? PinCategoryType.allCases.first) == type
                            DWSelectPin(
                                text: type.text,
                                isSelected: isSelectedPin,
                                action: { onCategorySelect(type) }
                            )
                            .colors(
                                selected: (bg: .primaryNormal, text: .white, border: .clear),
                                normal: (bg: .white, text: .labelAlternative, border: .clear)
                            )
                            .setIcon(type.icon)
                            .setIconSize(width: type.iconWidth, height: type.iconHeight)
                        }
                    }
                }
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(.horizontal, 20)
        .background(
            isSelected ? .primaryLight1 : .alternative
        )
        .cornerRadius(18)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)
    }
}

// MARK: - Preview

// #Preview {
//    VStack(spacing: 12) {
//        // 선택되지 않은 카드
//        ScanResultCard(
//            address: "부산 북구 화명동",
//            duplicateCount: 38,
//            isSelected: false,
//            selectedCategory: nil,
//            onToggleSelection: {},
//            onCategorySelect: { _ in }
//        )
//
//        // 선택된 카드 (카테고리 미선택)
//        ScanResultCard(
//            address: "부산 강서구 대저1동",
//            duplicateCount: 28,
//            isSelected: true,
//            selectedCategory: nil,
//            onToggleSelection: {},
//            onCategorySelect: { _ in }
//        )
//
//        // 선택된 카드 (카테고리 선택됨)
//        ScanResultCard(
//            address: "부산 강서구 대저2동",
//            duplicateCount: 18,
//            isSelected: true,
//            selectedCategory: .custom,
//            onToggleSelection: {},
//            onCategorySelect: { _ in }
//        )
//    }
//    .padding(16)
//    .background(Color(.systemGray6))
// }
