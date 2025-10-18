//
//  CountBadge.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/18/25.
//

import SwiftUI

struct CountBadge: View {
    var count: Int
    var body: some View {
        Text("\(count)")
            .font(.pretendardSemiBold(size: 24))
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .foregroundStyle(.mainBlue)
            .background(
                Color.backgroundBlue,
                in: RoundedRectangle(cornerRadius: 8)
            )
    }
}
