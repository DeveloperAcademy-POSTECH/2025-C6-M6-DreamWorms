//
//  DWToast.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/4/25.
//

import SwiftUI

/// Toast Component
/// message 는 필수값 입니다.
struct DWToast: View {
    let message: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(message)
                .font(.captionRegular13)
                .foregroundColor(.labelCoolNormal)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.toastBackground)
        .cornerRadius(100)
    }
}

struct DWToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    var duration: TimeInterval = 3.0
    
    @State private var task: Task<Void, Never>?
    
    init(isPresented: Binding<Bool>, message: String, duration: TimeInterval = 3.0) {
        self._isPresented = isPresented
        self.message = message
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                VStack {
                    DWToast(message: message)
                        .padding(.top, 56)
                    Spacer()
                }
            }
        }
        .onChange(of: isPresented) { _, newValue in
            Task { @MainActor in
                if newValue {
                    showToast()
                } else {
                    task?.cancel()
                    task = nil
                }
            }
        }
        .onChange(of: duration) { _, _ in
            if isPresented {
                showToast()
            }
        }
    }
    
    private func showToast() {
        task?.cancel()
        task = nil
        
        task = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.25)) {
                    isPresented = false
                }
            }
        }
    }
}

extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        duration: TimeInterval = 3.0
    ) -> some View {
        modifier(DWToastModifier(
            isPresented: isPresented,
            message: message,
            duration: duration
        ))
    }
}

#Preview {
    @Previewable @State var showToast = false

    VStack {
        DWCircleButton(image: Image(.camera), action: {
            showToast = true
        })
    }
    .toast(isPresented: $showToast, message: "toast sample")
}
