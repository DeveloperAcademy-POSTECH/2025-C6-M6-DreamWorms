//
//  CaseCard.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct CaseCard: View {
    let item: Case
    
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    
    @State private var showMenu = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(.caseCardNumber(number: item.number))
                        .font(.numberMedium15)
                        .foregroundStyle(.gray)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(item.name)
                            .font(.titleSemiBold18)
                            .foregroundStyle(.labelNormal)
                        Text(item.crime)
                            .font(.bodyMedium14)
                            .foregroundStyle(.labelAlternative)
                    }
                }
                Spacer()
                
                Image(.imgProfile)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
            }
            .padding(.top, 8)
            
            Divider()
                .background(.labelColorNormal)
                .padding(.bottom, 2)

            HStack {
                HStack(spacing: 4) {
                    Image(.person)
                    Text(item.suspect)
                }
                .font(.bodyMedium12)
                .foregroundStyle(.primaryNormal)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(.primaryLight2)
                .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()
                
                Menu {
                    Button {
                        onEdit()
                    } label: {
                        Label(
                            String(localized: .buttonEdit),
                            systemImage: SymbolLiterals.edit.rawValue
                        )
                    }
                    
                    Button {
                        onShare()
                    } label: {
                        Label(
                            String(localized: .buttonShare),
                            systemImage: SymbolLiterals.share.rawValue
                        )
                    }
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label(
                            String(localized: .buttonDelete),
                            systemImage: SymbolLiterals.delete.rawValue
                        )
                    }
                } label: {
                    Image(.icnMore)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .contentShape(Rectangle())
                }
                .menuActionDismissBehavior(.automatic)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.mainAlternative)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.labelColorNormal, lineWidth: 0.5)
                )
        )
    }
}

//#Preview {
//    CaseCard(
//        item: Case(
//            id: UUID(),
//            number: "12-2025",
//            title: "사건명",
//            crime: "범죄유형",
//            suspect: "피의자명"
//        ),
//        onEdit: {}, onShare: {}, onDelete: {}
//    )
//    .padding(.horizontal, 16)
//}
