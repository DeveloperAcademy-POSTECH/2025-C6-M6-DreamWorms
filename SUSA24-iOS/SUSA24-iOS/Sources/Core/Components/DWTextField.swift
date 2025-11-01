//
//  DWTextField.swift
//  SUSA24-iOS
//
//  Created by mini on 11/1/25.
//

import SwiftUI

// MARK: - TextField State

enum DWTextFieldState: Equatable {
    case normal
    case error(String)
    
    var borderColor: Color {
        switch self {
        case .normal: .clear
        case .error: .pointRed3
        }
    }
}

// MARK: - View

struct DWTextField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var state: DWTextFieldState = .normal
    var title: String?
    var placeholder: String?
    
    var contentPadding: EdgeInsets = .init(top: 18, leading: 20, bottom: 18, trailing: 12)
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.titleSemiBold14)
                    .foregroundStyle(.labelNeutral)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.mainAlternative)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(state.borderColor, lineWidth: 1)
                    .animation(.default, value: state)
                
                HStack {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder ?? "")
                            .foregroundColor(.labelAssistive)
                            .font(.bodyMedium14)
                    )
                    .focused($isFocused)
                    .font(.bodyMedium14)
                    .foregroundStyle(.labelNormal)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(keyboard)
                    .submitLabel(submitLabel)
                    .onSubmit { onSubmit?() }
                    
                    if isFocused, !text.isEmpty {
                        Button {
                            text = ""
                        } label: {
                            Image(.xmark)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(.labelAssistive)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(contentPadding)
            }
            .padding(.bottom, 2)
            
            Group {
                switch state {
                case .error(let message):
                    HStack(alignment: .center, spacing: 6) {
                        Image(.warningCircle)
                        Text(message)
                    }
                    .foregroundStyle(.pointRed1)
                default:
                    EmptyView()
                }
            }
            .font(.captionRegular12)
            .transition(.opacity)
        }
        .animation(.default, value: text)
    }
}

extension DWTextField {
    @discardableResult
    func setupState(_ state: DWTextFieldState) -> Self {
        var v = self; v.state = state; return v
    }

    @discardableResult
    func setupPadding(_ insets: EdgeInsets) -> Self {
        var v = self; v.contentPadding = insets; return v
    }
    
    @discardableResult
    func setupKeyboard(
        _ type: UIKeyboardType,
        submit: SubmitLabel = .done,
        onSubmit: (() -> Void)? = nil
    ) -> Self {
        var v = self
        v.keyboard = type; v.submitLabel = submit; v.onSubmit = onSubmit
        return v
    }
}

//#Preview("DWTextField States") {
//    VStack(spacing: 40) {
//        DWTextField(
//            text: .constant(""),
//            placeholder: "사건번호를 입력해 주세요."
//        )
//        .frame(height: 56)
//        
//        DWTextField(
//            text: .constant(""),
//            title: "사건번호",
//            placeholder: "사건번호를 입력해 주세요."
//        )
//        .frame(height: 82)
//        
//        DWTextField(
//            text: .constant("dsd"),
//            state: .error("텍스트를 입력해 주세요."),
//            title: "피의자명",
//            placeholder: "사건번호를 입력해 주세요."
//        )
//        .frame(height: 82)
//    }
//    .padding(16)
//}
