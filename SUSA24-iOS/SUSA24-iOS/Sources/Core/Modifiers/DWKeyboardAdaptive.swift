//
//  DWKeyboardAdaptive.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import Combine
import SwiftUI

enum KeyboardHeightPublisher {
    static let shared: AnyPublisher<CGFloat, Never> = {
        let keyboardWillShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map(\.height)

        let keyboardWillHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }()
}

struct DWKeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(KeyboardHeightPublisher.shared) { height in
                withAnimation { keyboardHeight = height }
            }
    }
}

extension View {
    func dreamwormsKeyboardAdaptive() -> some View {
        modifier(DWKeyboardAdaptive())
    }
}
