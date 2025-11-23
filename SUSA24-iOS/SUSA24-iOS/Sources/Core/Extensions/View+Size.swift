//
//  View+Size.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/23/25.
//

import SwiftUI

extension View {
    func onScreen(_ handler: @escaping @MainActor (UIScreen?) -> Void) -> some View {
        background(
            ScreenReader(handler: handler)
                .frame(width: 0, height: 0)
        )
    }
}

private struct ScreenReader: UIViewRepresentable {
    let handler: @MainActor (UIScreen?) -> Void
    
    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        
        Task { @MainActor in
            let screen = view.window?.windowScene?.screen
            handler(screen)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context _: Context) {
        Task { @MainActor in
            let screen = uiView.window?.windowScene?.screen
            handler(screen)
        }
    }
}
