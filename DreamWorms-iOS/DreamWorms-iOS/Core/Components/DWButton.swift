//
//  DWButton.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI

struct DWButton: View {
    private let title: String
    private let iconImage: Image?
    private let action: () -> Void
    
    private(set) var isEnabled: Bool
    
    init(
        title: String,
        iconImage: Image? = nil,
        isEnabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconImage = iconImage
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconImage {
                    iconImage
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.pretendardSemiBold(size: 16))
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: 56)
            .foregroundStyle(.white)
            .background(isEnabled ? .mainBlue : .disabledGray)
            .cornerRadius(8)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onTapGesture {
            guard isEnabled else { return }
            triggerMediumHapticFeedback()
        }
    }
}

#Preview {
    DWButton(title: "추가하기", iconImage: Image(.icnPlus20), action: {})
    DWButton(title: "추가하기", isEnabled: true, action: {})
    DWButton(title: "추가하기", iconImage: Image(.icnPin18), isEnabled: true, action: {})
}
