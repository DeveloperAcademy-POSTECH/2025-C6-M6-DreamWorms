//
//  SearchResultsList.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/7/25.
//

import SwiftUI

/// 검색 결과 리스트 뷰
struct SearchResultsList: View {
    let items: [SearchResultItem]
    let onItemSelected: (SearchResultItem) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    onItemSelected(item)
                } label: {
                    SearchListItem(item: item)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if item.id != items.last?.id {
                    Divider()
                        .background(.labelAssistive)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - SearchListItem

/// 검색 결과 리스트 항목
struct SearchListItem: View {
    let item: SearchResultItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 왼쪽 아이콘
            Image(.icnFillPlace)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(.labelAssistive)
                .background {
                    Circle()
                        .fill(.mainAlternative)
                        .frame(width: 32, height: 32)
                }
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.bodyMedium16)
                    .foregroundStyle(.labelNormal)
                
                Text(item.roadAddress.isEmpty ? item.jibunAddress : item.roadAddress)
                    .font(.bodyRegular14)
                    .foregroundStyle(.labelAlternative)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
    
// #Preview("SearchResultsList") {
//    SearchResultsList(
//        items: [
//            SearchResultItem(
//                id: "1",
//                title: "주소",
//                jibunAddress: "지번 주소",
//                roadAddress: "도로명 주소",
//                phoneNumber: "010-1234-5678",
//                latitude: 35.0,
//                longitude: 129.0
//            ),
//            SearchResultItem(
//                id: "2",
//                title: "주소",
//                jibunAddress: "지번 주소",
//                roadAddress: "도로명 주소",
//                phoneNumber: "",
//                latitude: 35.1,
//                longitude: 128.9
//            ),
//            SearchResultItem(
//                id: "3",
//                title: "주소",
//                jibunAddress: "지번 주소",
//                roadAddress: "",
//                phoneNumber: "",
//                latitude: 35.2,
//                longitude: 128.8
//            ),
//        ],
//        onItemSelected: { _ in }
//    )
//    .padding()
//    .background(.mainBackground)
// }
