//
//  SearchResultRow.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/19/25.
//

import SwiftUI

struct SearchResultRow: View {
    let placeName: String
    let address: String
    let category: String
    let distance: String
    let reviewCount: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.gray8B)
                
                PlaceInfoView(
                    placeName: placeName,
                    address: address,
                    reviewCount: reviewCount
                )
                
                Spacer()
                
                DistanceInfoView(
                    category: category,
                    distance: distance
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PlaceInfoView 서브뷰

struct PlaceInfoView: View {
    let placeName: String
    let address: String
    let reviewCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeName)
                .font(.pretendardSemiBold(size: 16))
                .foregroundStyle(Color.black22)
            
            Text(address)
                .font(.pretendardRegular(size: 14))
                .foregroundStyle(Color.gray8B)
                .lineLimit(1)
            
            Text("리뷰 \(reviewCount)")
                .font(.pretendardRegular(size: 12))
                .foregroundStyle(Color.gray8B)
        }
    }
}

// MARK: - DistanceInfoView 서브뷰

struct DistanceInfoView: View {
    let category: String
    let distance: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(category)
                .font(.pretendardRegular(size: 12))
                .foregroundStyle(Color.gray8B)
            
            Text(distance)
                .font(.pretendardSemiBold(size: 14))
                .foregroundStyle(Color.black22)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SearchResultRow(
            placeName: "GS25 포항북부점",
            address: "경북 포항시 남구 복성동 54 (주차장 597)",
            category: "편의점",
            distance: "1.5km",
            reviewCount: 497
        ) {
            print("선택됨")
        }
        
        Divider()
        
        SearchResultRow(
            placeName: "CU 포항중성지센터점",
            address: "경북 포항시 남구 중성동62번길 10 (주차장)",
            category: "편의점",
            distance: "1.6km",
            reviewCount: 234
        ) {
            print("선택됨")
        }
    }
}
