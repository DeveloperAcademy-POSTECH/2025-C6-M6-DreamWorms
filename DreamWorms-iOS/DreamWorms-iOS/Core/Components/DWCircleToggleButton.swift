//
//  DWCircleToggleButton.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import SwiftUI

struct DWCircleToggleButton: View {
    let title: String?
    let systemImage: String?
    
    @Binding var isOn: Bool
    
    let action: (() -> Void)?
    
    init(
        title: String? = nil,
        systemImage: String? = nil,
        isOn: Binding<Bool>,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self._isOn = isOn
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            isOn.toggle()
            action?()
        }) {
            if let systemImage {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isOn ? .mainBlue : .mainBlack)
            } else if let title {
                Text(title)
                    .font(.pretendardSemiBold(size: 12))
                    .foregroundColor(isOn ? .mainBlue : .mainBlack)
            }
        }
        .frame(width: 40, height: 40)
        .background(.white)
        .clipShape(Circle())
        .shadow(color: .mainBlack.opacity(0.15), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    VStack {
        DWCircleToggleButton(systemImage: "scope", isOn: .constant(true)) {
        }
        
        DWCircleToggleButton(title: "반경", isOn: .constant(false)) {
        }
        
        DWCircleToggleButton(title: "빈도", isOn: .constant(true)) {
        }
    }
}
