//
//  CaseCard.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/18/25.
//

import SwiftUI

struct CaseCard: View {
    let item: Case
    
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(.caseCardCaseNumber(number: item.number))
                    .font(.pretendardSemiBold(size: 14))
                    .foregroundStyle(.gray98)
                Spacer().foregroundStyle(.grayE5)
                Menu {
                    Button(.btnEdit, action: onEdit)
                    Button(.btnDelete, role: .destructive, action: onDelete)
                } label: {
                    Image(.icnEdit24)
                        .renderingMode(.template)
                        .foregroundStyle(.gray4A)
                        .contentShape(Rectangle())
                }
                .menuStyle(.automatic)
            }
            Divider()
            Text(item.name)
                .font(.pretendardMedium(size: 18))
                .foregroundStyle(.black22)
            HStack(spacing: 4) {
                Image(.icnMy18)
                    .renderingMode(.template)
                Text(item.suspectName)
                    .font(.pretendardMedium(size: 12))
            }
            .foregroundStyle(.black22)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.grayF2, in: RoundedRectangle(cornerRadius: 4))
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.grayFB)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.grayE5, lineWidth: 1)
        )
    }
}

#Preview {
    CaseCard(
        item: Case(name: "대구 청테이프", number: "1", suspectName: "피의자명"),
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
