//
//  View+Size.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/23/25.
//

import SwiftUI

extension View {
    /// 현재 뷰가 포함된 **스크린 정보를 읽어올 때** 사용합니다.
    ///
    /// - Parameter handler: 화면(Screen) 정보를 전달받는 클로저
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
