//
//  DWAlertButton.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/10/25.
//

import SwiftUI

struct DWAlertButton {
    let title: String
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case `default`
        case destructive
        case cancel

        var defaultTitle: String {
            switch self {
            case .default: return "확인"
            case .destructive: return "삭제"
            case .cancel: return "취소"
            }
        }
    }

    init(
        title: String? = nil,
        style: ButtonStyle = .default,
        action: @escaping () -> Void = {}
    ) {
        self.style = style
        self.title = title ?? style.defaultTitle
        self.action = action
    }
}


struct DWAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let title: String
    let message: String?
    let primaryButton: DWAlertButton
    let secondaryButton: DWAlertButton?
    
    // 배경색 제스쳐로 화면 닫을 것인지
    let tapToDismiss: Bool
    
    init(isPresented: Binding<Bool>, title: String, message: String?, primaryButton: DWAlertButton, secondaryButton: DWAlertButton? = nil, tapToDismiss: Bool = false) {
        _isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.tapToDismiss = tapToDismiss
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if !tapToDismiss { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text(title)
                            .font(.titleSemiBold16)
                            .foregroundStyle(.labelNormal)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let message {
                            Text(message)
                                .font(.bodyRegular14)
                                .foregroundStyle(.labelNeutral)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)
                    
                    HStack(spacing: 8) {
                        if let secondaryButton {
                            alertButton(secondaryButton, isPrimary: false)
                                .padding(.trailing, 2)
                        }
                        alertButton(primaryButton, isPrimary: true)
                    
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(width: 300)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
    }
    
    private func alertButton(_ button: DWAlertButton, isPrimary: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPresented = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                button.action()
            }
        } label: {
            Text(button.title)
                .font(.titleSemiBold16)
                .foregroundStyle(textColor(for: button.style, isPrimary: isPrimary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(backgroundColor(for: button.style, isPrimary: isPrimary))
                .cornerRadius(100)
        }
        .buttonStyle(.plain)
    }
    
    private func textColor(for style: DWAlertButton.ButtonStyle, isPrimary: Bool) -> Color {
        switch style {
        case .destructive:
            return .white
        case .cancel:
            return .labelNormal
        case .default:
            return isPrimary ? .white : .labelNormal
        }
    }
    
    private func backgroundColor(for style: DWAlertButton.ButtonStyle, isPrimary: Bool) -> Color {
        switch style {
        case .destructive:
            return .pointRed1
        case .cancel:
            return .labelAlternative.opacity(0.45)
        case .default:
            return isPrimary ? .primaryNormal : .labelAlternative.opacity(0.45)
        }
    }
}

extension View {
    func dwAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        primaryButton: DWAlertButton,
        secondaryButton: DWAlertButton? = nil
    ) -> some View {
        modifier(
            DWAlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        )
    }
    
    func dwAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        action: @escaping () -> Void = {}
    ) -> some View {
        dwAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButton: DWAlertButton(title: "확인", action: action)
        )
    }
}

// MARK: - Preview
//
//#Preview("Alert 사용 방법") {
//    struct PreviewContainer: View {
//        @State private var showBasicAlert = false
//        @State private var showDestructiveAlert = false
//        @State private var showSingleAlert = true
//        
//        var body: some View {
//            VStack(spacing: 20) {
//                Button("기본 Alert") {
//                    showBasicAlert = true
//                }
//                
//                Button("Destructive Alert") {
//                    showDestructiveAlert = true
//                }
//                
//                Button("단일 버튼 Alert") {
//                    showSingleAlert = true
//                }
//            }
//            .dwAlert(
//                isPresented: $showBasicAlert,
//                title: "저장하시겠습니까?",
//                message: "변경사항을 저장하시겠습니까?",
//                primaryButton: DWAlertButton(title: "저장") {
//                    print("저장됨")
//                },
//                secondaryButton: DWAlertButton(style: .cancel)
//            )
//            .dwAlert(
//                isPresented: $showDestructiveAlert,
//                title: "핀 덮어쓰기",
//                message: "기존에 '부산 강서구 대저2동'에 저장된 핀이 있습니다. 기존 내용을 지우고 덮어쓸까요?",
//                primaryButton: DWAlertButton(title: "덮어쓰기", style: .destructive) {
//                    print("덮어쓰기 눌렀음")
//                },
//                secondaryButton: DWAlertButton(title: "취소", style: .cancel)
//            )
//            .dwAlert(
//                isPresented: $showSingleAlert,
//                title: "작업 완료",
//                message: "모든 작업이 성공적으로 완료되었습니다."
//            ) {
//                print("확인을 눌렀음")
//            }
//        }
//    }
//    
//    return PreviewContainer()
//}
