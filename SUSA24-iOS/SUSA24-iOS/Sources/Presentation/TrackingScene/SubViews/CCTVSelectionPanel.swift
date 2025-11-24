//
//  CCTVSelectionPanel.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

// MARK: - CCTV Selection Panel

struct CCTVSelectionPanel: View {
    /// 각 슬롯에 들어갈 핀 이름 (nil 이면 아직 선택 안 된 상태)
    @Binding var slotTitles: [String?]
    
    /// 빈 슬롯을 탭했을 때 지도에서 선택 모드로 전환하는 콜백
    var onSelectSlot: (Int) -> Void
    
    /// 뒤로가기 버튼 탭 콜백
    var onBack: () -> Void
    
    /// 완료 버튼 탭 콜백
    var onDone: () -> Void
    
    /// 특정 Slot 삭제 콜백
    var onClearSlot: (Int) -> Void
    
    // 하나라도 선택되어 있어야 완료 버튼 활성화
    private var canFinish: Bool {
        slotTitles.allSatisfy { $0 != nil }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                DWGlassEffectCircleButton(
                    image: Image(.back),
                    action: onBack
                )
                .setupSize(44)
                .setupIconSize(18)
                
                Spacer()
                                
                Text(.trackingNavigationTitle)
                    .font(.titleSemiBold16)
                    .foregroundStyle(.labelNormal)
                
                Spacer()
                
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.top, 18)
            
            VStack(spacing: 6) {
                ForEach(slotTitles.indices, id: \.self) { index in
                    CCTVSlotRow(
                        title: Binding(
                            get: { slotTitles[index] },
                            set: { slotTitles[index] = $0 }
                        ),
                        onClear: { onClearSlot(index) }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if slotTitles[index] == nil {
                            onSelectSlot(index)
                        }
                    }
                }
            }
            
            DWButton(
                isEnabled: .constant(canFinish),
                title: String(localized: .mapviewPinCreateButton),
                action: onDone
            )
            .setupVerticalPadding(15)
            .setupFont(.titleSemiBold14)
        }
        .padding(.top, 52)
        .padding([.bottom, .horizontal], 16)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.25), radius: 16)
        )
        .ignoresSafeArea()
    }
}

// MARK: - CCTV Slot Row

struct CCTVSlotRow: View {
    @Binding var title: String?
    var onClear: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title ?? "지도에서 핀을 선택해 주세요")
                .font(.bodyRegular14)
                .foregroundStyle(
                    title == nil ? Color.labelAlternative : Color.labelNormal
                )
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(height: 42)
            
            Spacer()
            
            if title != nil {
                Button(action: { onClear?() }) {
                    Image(.minus)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.labelNeutral)
                        .frame(width: 22, height: 22)
                        .background(
                            Circle()
                                .stroke(.labelCoolNormal, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .frame(height: 42)
        .overlay(
            Capsule().stroke(.labelCoolNormal, lineWidth: 1)
        )
    }
}

// #Preview {
//    struct CCTVSelectionPanel_PreviewWrapper: View {
//        @State var slots: [String?] = [
//            "아아여기는선택된핀의이름이들어갑니다최대이렇게…",
//            nil,
//            nil,
//        ]
//
//        var body: some View {
//            ZStack {
//                Color.red.opacity(0.2).ignoresSafeArea()
//            }
//            .safeAreaInset(edge: .top) {
//                CCTVSelectionPanel(
//                    slotTitles: $slots,
//                    onSelectSlot: { index in
//                        // 데모용: 탭하면 임시 이름 채워주기
//                        slots[index] = "선택된 CCTV \(index + 1)"
//                    },
//                    onBack: {},
//                    onDone: {
//                        print("완료 탭: \(slots)")
//                    }
//                )
//            }
//            .ignoresSafeArea(edges: .all)
//        }
//    }
//
//    return CCTVSelectionPanel_PreviewWrapper()
// }
