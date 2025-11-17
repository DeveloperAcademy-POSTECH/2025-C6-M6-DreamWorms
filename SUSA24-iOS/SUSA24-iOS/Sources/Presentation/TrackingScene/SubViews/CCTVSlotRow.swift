//
//  CCTVSlotRow.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct CCTVSlotRow: View {
    @Binding var title: String?
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title ?? "지도에서 핀을 선택해 주세요")
                .font(.bodyRegular14)
                .foregroundStyle(
                    title == nil ? Color.labelAlternative : Color.labelNormal
                )
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            if title != nil {
                Button(action: { title = nil }) {
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
//    @Previewable @State var title: String? = nil
//    @Previewable @State var title2: String? = "아아여기는선택된핀의이름이들어갑니다최대이렇게"
//
//    VStack {
//        CCTVSlotRow(title: $title)
//        CCTVSlotRow(title: $title2)
//    }
//    .padding(.horizontal, 16)
// }
