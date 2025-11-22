//
//  ScanResultCard.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import SwiftUI

// MARK: - View

/// 스캔된 주소 컴포넌트 카드
struct ScanResultCard: View {
    // MARK: - Properties

    let roadAddress: String
    let jibunAddress: String
    let duplicateCount: Int
    let isSelected: Bool
    let selectedCategory: PinCategoryType?
    let onToggleSelection: () -> Void
    let onCategorySelect: (PinCategoryType) -> Void
    
    // MARK: - State
    
    @State private var isShowingJibunAddress: Bool = false
    
    // MARK: - Computed Properties
    
    /// 신주소 우선, 없으면 구주소
    private var displayAddress: String {
        roadAddress.isEmpty ? jibunAddress : roadAddress
    }
    
    /// 신주소와 구주소 둘 다 있는지
    private var hasBothAddresses: Bool {
        !roadAddress.isEmpty && !jibunAddress.isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    // 주소 표시 영역
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .center, spacing: 8) {
                            Text(displayAddress)
                                .font(.bodyMedium16)
                                .foregroundStyle(.labelNormal)
                                .lineLimit(2)
                            
                            // 신주소/구주소 둘 다 있으면 토글 버튼 표시
                            if hasBothAddresses {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isShowingJibunAddress.toggle()
                                    }
                                }) {
                                    Image(isShowingJibunAddress ? .chevronUp : .chevronDown)
                                        .font(.captionRegular12)
                                        .foregroundStyle(.labelAlternative)
                                }
                                .buttonStyle(.borderless)
                                .padding(.bottom, 4)
                            }
                        }
                        
                        // 구주소 표시 (토글 시)
                        if hasBothAddresses, isShowingJibunAddress {
                            Text(jibunAddress)
                                .font(.captionRegular12)
                                .foregroundStyle(.labelAlternative)
                                .lineLimit(2)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    
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
            }
            .padding(.top, 14)
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

#Preview {
    VStack(spacing: 12) {
        // 신주소만 있는 카드
        ScanResultCard(
            roadAddress: "부산광역시 북구 화명대로 7",
            jibunAddress: "",
            duplicateCount: 38,
            isSelected: false,
            selectedCategory: nil,
            onToggleSelection: {},
            onCategorySelect: { _ in }
        )

        // 구주소만 있는 카드
        ScanResultCard(
            roadAddress: "",
            jibunAddress: "부산 강서구 대저1동 123-45",
            duplicateCount: 28,
            isSelected: false,
            selectedCategory: nil,
            onToggleSelection: {},
            onCategorySelect: { _ in }
        )
        
        // 신주소/구주소 둘 다 있는 카드
        ScanResultCard(
            roadAddress: "부산광역시 강서구 공항로 두 줄이 넘어가는 긴 주소 108",
            jibunAddress: "부산 강서구 대저2동 2350",
            duplicateCount: 18,
            isSelected: true,
            selectedCategory: .custom,
            onToggleSelection: {},
            onCategorySelect: { _ in }
        )
    }
    .padding(16)
    .background(Color(.systemGray6))
}
