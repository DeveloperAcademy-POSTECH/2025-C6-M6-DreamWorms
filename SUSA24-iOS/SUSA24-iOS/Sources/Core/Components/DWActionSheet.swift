//
//  DWActionSheet.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/16/25.
//

import SwiftUI

// MARK: - ActionSheet Item

struct DWActionSheetItem: Identifiable {
    let id = UUID()
    let title: String
    let role: Role
    let action: () -> Void
    
    enum Role {
        case `default`
        case destructive
        case cancel
        
        var color: Color {
            switch self {
            case .default: .labelAlternative
            case .destructive: .red
            case .cancel: .primaryNormal
            }
        }
    }
    
    static func `default`(_ title: String, action: @escaping () -> Void) -> Self {
        .init(title: title, role: .default, action: action)
    }
    
    static func destructive(_ title: String, action: @escaping () -> Void) -> Self {
        .init(title: title, role: .destructive, action: action)
    }
    
    static func cancel(_ title: String = String(localized: .cancelDefault), action: @escaping () -> Void = {}) -> Self {
        .init(title: title, role: .cancel, action: action)
    }
}

extension UIApplication {
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
}

final class DWActionSheetPresenter {
    static let shared = DWActionSheetPresenter()
    private init() {}
    
    private var hostingView: UIView?
    
    func present(_ view: some View) {
        guard let window = UIApplication.keyWindow else { return }
        
        // 이미 떠있으면 제거하고 새로 추가
        dismiss()
        
        let hosting = UIHostingController(rootView: view)
        hosting.view.frame = window.bounds
        hosting.view.backgroundColor = .clear
        // tag가 있어야 해당 뷰를 찾아서 지울 수 있음
        hosting.view.tag = 1000
        
        window.addSubview(hosting.view)
        hostingView = hosting.view
    }
    
    func dismiss() {
        hostingView?.removeFromSuperview()
        hostingView = nil
    }
}

// MARK: - ActionSheet Root View (Full Screen)

struct DWActionSheetView: View {
    let title: String?
    let message: String?
    let items: [DWActionSheetItem]
    let dismiss: () -> Void
    
    private var cancelItem: DWActionSheetItem? {
        items.first(where: { $0.role == .cancel })
    }
    
    private var actionItems: [DWActionSheetItem] {
        items.filter { $0.role != .cancel }
    }
    
    @State private var appear = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // DIM Background
            Color.black.opacity(appear ? 0.35 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            VStack(spacing: 12) {
                // Action Items Group
                VStack(spacing: 0) {
                    if title != nil || message != nil {
                        VStack(spacing: 4) {
                            if let title {
                                Text(title)
                                    .font(.titleSemiBold16)
                                    .foregroundColor(.labelAlternative)
                                    .multilineTextAlignment(.center)
                            }
                            if let message {
                                Text(message)
                                    .font(.bodyRegular14)
                                    .foregroundColor(.labelAlternative)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(16)
                        
                        Divider()
                            .background(.labelAlternative.opacity(0.3))
                    }
                    
                    ForEach(actionItems) { item in
                        Button {
                            item.action()
                            dismiss()
                        } label: {
                            Text(item.title)
                                .font(.bodyRegular14)
                                .foregroundColor(item.role.color)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        
                        if item.id != actionItems.last?.id {
                            Divider()
                                .background(.labelAlternative.opacity(0.3))
                        }
                    }
                }
                .background(.regularMaterial)
                .cornerRadius(14)
                .padding(.horizontal, 12)
                .offset(y: appear ? 0 : 50)
                .opacity(appear ? 1 : 0)
                
                if let cancelItem {
                    Button {
                        cancelItem.action()
                        dismiss()
                    } label: {
                        Text(cancelItem.title)
                            .font(.bodyRegular14)
                            .foregroundColor(cancelItem.role.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(.regularMaterial)
                    .cornerRadius(14)
                    .padding(.horizontal, 12)
                    .offset(y: appear ? 0 : 50)
                    .opacity(appear ? 1 : 0)
                }
            }
            .padding(.bottom, 20)
        }
        .animation(.easeOut(duration: 0.22), value: appear)
        .onAppear { appear = true }
    }
}

// MARK: - Modifier

struct GlobalActionSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let items: [DWActionSheetItem]
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    DWActionSheetPresenter.shared.present(
                        DWActionSheetView(
                            title: title,
                            message: message,
                            items: items,
                            dismiss: { isPresented = false }
                        )
                    )
                } else {
                    DWActionSheetPresenter.shared.dismiss()
                }
            }
    }
}

extension View {
    func dwActionSheet(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String? = nil,
        items: [DWActionSheetItem]
    ) -> some View {
        modifier(
            GlobalActionSheetModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                items: items
            )
        )
    }
}

//
//// MARK: - Preview
//
// #Preview {
//    DemoPreview()
// }
//
// struct DemoPreview: View {
//    @State private var showSheet = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Button("액션시트") {
//                showSheet = true
//            }
//        }
//        .dwActionSheet(
//            isPresented: $showSheet,
//            title: "선택하세요",
//            message: "테스트 메시지입니다",
//            items: [
//                //                .default("옵션 1") { print("1") },
//                .destructive("삭제") { print("delete") },
////                .cancel("취소"),
//            ]
//        )
//    }
// }
