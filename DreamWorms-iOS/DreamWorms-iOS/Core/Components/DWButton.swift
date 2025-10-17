//
//  DWButton.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI

struct DWButton: View {
    private let title: String
    private let action: () -> Void
    
    init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.pretendardSemiBold(size: 16))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, maxHeight: 56)
                .foregroundStyle(.white)
                .background(.mainBlue)
                .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
