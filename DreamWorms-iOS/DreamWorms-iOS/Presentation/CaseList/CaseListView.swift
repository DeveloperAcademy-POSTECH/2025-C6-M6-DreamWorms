//
//  CaseListView.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftData
import SwiftUI

struct CaseListView: View {
    @EnvironmentObject
    private var coordinator: AppCoordinator
    
    @Environment(\.modelContext)
    private var context
    
    @Query
    private var cases: [Case]

    // TODO: - 모델 구조가 완성되면 그때 이부분 수정 필요
    private var completedCount: Int { cases.count }
    
    var body: some View {
        NavigationStack {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(.caseListCurrent)
                    HStack(spacing: 6) {
                        Text(.caseListCompleteCase).padding(.trailing, 2)
                        CountBadge(count: completedCount)
                        Text(.count)
                    }
                }
                .font(.pretendardSemiBold(size: 24))
                Spacer()
            }
            .padding(.top, 68)
            .padding(.leading, 16)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(cases) { item in
                        Button {
                            coordinator.push(.map)
                        } label: {
                            // TODO: - 모델 연결이후, 수정하기 삭제하기 작업 추가
                            CaseCard(
                                item: item,
                                onEdit: {},
                                onDelete: {}
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 28)
            
            DWButton(
                title: String(localized: .btnAddCase),
                iconImage: Image(.icnPlus20),
                isEnabled: true
            ) {
                coordinator.push(.caseAdd)
            }
        }
    }
}
