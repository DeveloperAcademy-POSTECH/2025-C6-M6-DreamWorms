//
//  CCTVSelectionPanel.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct CCTVSelectionPanel: View {
    /// 각 슬롯에 들어갈 핀 이름 (nil 이면 아직 선택 안 된 상태)
    @Binding var slotTitles: [String?]
    
    /// 빈 슬롯을 탭했을 때 지도에서 선택 모드로 전환하는 콜백
    var onSelectSlot: (Int) -> Void
    
    /// 뒤로가기 버튼 탭 콜백
    var onBack: () -> Void
    
    /// 완료 버튼 탭 콜백
    var onDone: () -> Void
    
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
                        )
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
                action: {}
            )
            .setupVerticalPadding(13.5)
            .setupFont(.titleSemiBold14)
        }
        .padding(.top, 58)
        .padding([.bottom, .horizontal], 16)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.25), radius: 16)
        )
        .ignoresSafeArea()
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
