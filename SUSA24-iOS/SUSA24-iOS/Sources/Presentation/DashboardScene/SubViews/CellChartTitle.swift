//
//  CellChartTitle.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import SwiftUI

struct CellChartTitle: View {
    var address: String
    var summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(address.isEmpty ? "이" : address) 기지국에서")
                .font(.bodyMedium12)
                .foregroundStyle(.primaryNormal)
                .padding(.vertical, 4)
                .padding(.horizontal, 5)
                .background(.primaryLight2)
                .cornerRadius(4)
            
            Text("\(summary.isEmpty ? "주로 머무는 시간대를 확인하세요." : summary)")
                .font(.titleSemiBold18)
                .foregroundStyle(summary.isEmpty ? .labelAssistive : .labelNormal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
