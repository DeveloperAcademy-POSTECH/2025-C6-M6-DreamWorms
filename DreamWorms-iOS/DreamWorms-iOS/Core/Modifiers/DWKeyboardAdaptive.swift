//
//  DWKeyboardAdaptive.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import Combine
import SwiftUI

struct DWKeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    private let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { notification in
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        }
        .map { rect in
            rect.height
        }
    
    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat(0) }
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(
                Publishers.Merge(keyboardWillShow, keyboardWillHide)
            ) { height in
                withAnimation {
                    keyboardHeight = height
                }
            }
    }
}

extension View {
    func dreamwormsKeyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: DWKeyboardAdaptive())
    }
}
