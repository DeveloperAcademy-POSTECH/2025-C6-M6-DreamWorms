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
    let onDelete: () -> Void
    let onAddCellLog: () -> Void
    
    @State private var showMenu = false
    @State private var showDeleteAlert = false

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
                
                if let path = item.suspectProfileImage,
                   let uiImage = ImageFileStorage.loadProfileImage(from: path)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else {
                    Image(.imgProfile)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 8)
            
            Divider()
                .background(.labelCoolNormal)
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
                    
                    // 1116 mock 데이터 추가 버튼
                    Button {
                        onAddCellLog()
                    } label: {
                        Label(
                            "기지국데이터 추가",
                            systemImage: "antenna.radiowaves.left.and.right"
                        )
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
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
                        .stroke(.labelCoolNormal, lineWidth: 0.5)
                )
        )
        .alert(
            String(localized: .caseListAlertTitle),
            isPresented: $showDeleteAlert
        ) {
            Button(String(localized: .buttonDelete), role: .destructive) {
                onDelete()
            }
            Button(String(localized: .cancelDefault), role: .cancel) {}
        } message: {
            Text(.caseListAlertDescription)
        }
    }
}
//
//#Preview {
//    CaseCard(
//        item: Case(
//            id: UUID(),
//            number: "12-2025",
//            name: "사건명",
//            crime: "범죄유형",
//            suspect: "피의자명"
//        ),
//        onEdit: {},
//        onDelete: {},
//        onAddCellLog: {}
//    )
//    .padding(.horizontal, 16)
//}
