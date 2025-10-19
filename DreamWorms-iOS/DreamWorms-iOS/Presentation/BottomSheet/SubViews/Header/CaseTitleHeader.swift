//
//  CaseTitleHeader.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

/// 헤더 제목
///
/// 역할: 사건명 표시만
struct CaseTitleHeader: View {
    let caseName: String
    
    var body: some View {
        Text(caseName)
            .font(.pretendardSemiBold(size: 20))
            .foregroundStyle(Color.black22)
    }
}

// MARK: - Preview

#Preview {
    CaseTitleHeader(caseName: "베트콩 소탕")
}
