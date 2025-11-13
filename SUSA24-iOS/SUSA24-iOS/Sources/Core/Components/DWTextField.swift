//
//  DWTextField.swift
//  SUSA24-iOS
//
//  Created by mini on 11/1/25.
//

import SwiftUI

// MARK: - TextField State

/// `DWTextField`의 상태를 정의하는 열거형입니다.
///
/// 이 타입은 텍스트 필드의 **테두리 색상**, **에러 메시지 표시 여부** 등을 제어합니다.
/// - Note: `.error` 상태일 때는 필드의 높이가 늘어나며 에러 메시지가 자연스럽게 표시됩니다.
enum DWTextFieldState: Equatable {
    /// 기본(normal) 상태입니다.
    case normal
    /// 에러가 발생했을 때의 상태입니다. 에러 메시지를 함께 가집니다.
    case error(String)
    
    var borderColor: Color {
        switch self {
        case .normal: .clear
        case .error: .pointRed3
        }
    }
    
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}

// MARK: - View

/// 폼 입력을 위한 **커스텀 텍스트 필드 컴포넌트**입니다.
struct DWTextField<Field: Hashable>: View {
    /// 바인딩된 텍스트 값입니다.
    @Binding var text: String
    
    /// 필드 식별자입니다. `FocusState`를 구분하는 데 사용됩니다.
    let field: Field
    /// 외부에서 전달된 포커스 상태입니다. 없으면 내부 포커스를 사용합니다.
    let externalFocus: FocusState<Field?>.Binding?
    @FocusState private var internalFocus: Field?
    
    /// 제목 (필드 위에 표시됩니다)
    var title: String?
    /// 플레이스홀더 (필드 안에 표시됩니다)
    var placeholder: String?
    /// 에러 메시지 (포커스 중이며 비어 있을 때 표시됩니다)
    var errorMessage: String?
    
    /// 텍스트 입력 영역의 패딩
    var contentPadding: EdgeInsets = .init(top: 18, leading: 20, bottom: 18, trailing: 12)
    /// 키보드 타입
    var keyboard: UIKeyboardType = .default
    /// 키보드 하단 리턴 버튼 타입
    var submitLabel: SubmitLabel = .done
    /// 리턴 버튼 탭 시 실행되는 액션
    var onSubmit: (() -> Void)?
    /// 텍스트 필드의 높이입니다. nil이면 기본 높이를 사용합니다.
    var height: CGFloat?
    /// 텍스트 필드의 배경색입니다.
    var backgroundColor: Color = .mainAlternative
    
    // 에러 메시지 관리용 상태 (최초 진입 때는 텍스트필드 밑에 에러 메시지를 보이지 않게 한다.)
    @State private var isValidationActive: Bool = false

    private var focus: FocusState<Field?>.Binding {
        externalFocus ?? $internalFocus
    }

    private var isFocused: Bool {
        focus.wrappedValue == field
    }

    private var currentState: DWTextFieldState {
        if let errorMessage, isValidationActive, text.isEmpty {
            return .error(errorMessage)
        }
        return .normal
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.titleSemiBold14)
                    .foregroundStyle(.labelNeutral)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(backgroundColor)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(currentState.borderColor, lineWidth: 1)
                    .animation(.easeInOut(duration: 0.2), value: currentState.isError)
                
                HStack {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder ?? "")
                            .foregroundColor(.labelAssistive)
                            .font(.bodyMedium14)
                    )
                    .focused(focus, equals: field)
                    .font(.bodyMedium14)
                    .foregroundStyle(.labelNormal)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(keyboard)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            isValidationActive = true
                        } else {
                            onSubmit?()
                        }
                    }
                    
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
                        .transition(.opacity)
                    }
                }
                .padding(contentPadding)
            }
            .padding(.bottom, 2)
            
            Group {
                switch currentState {
                case let .error(message):
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
        }
        .frame(height: height ?? (currentState.isError ? 104 : 82))
        .animation(.snappy(duration: 0.2), value: currentState.isError)
        .animation(.snappy(duration: 0.2), value: text)
        .onChange(of: text) { oldValue, newValue in
            if !isValidationActive, oldValue != newValue {
                isValidationActive = true
            }
        }
    }
}

// MARK: - Style

extension DWTextField {
    /// 텍스트 필드가 비어 있고 포커스 중일 때 표시할 에러 메시지를 설정합니다.
    ///
    /// - Parameter message: 사용자에게 보여질 에러 메시지
    /// - Note: 포커스가 해제되면 에러 메시지는 자동으로 사라집니다.
    @discardableResult
    func setupErrorMessage(_ message: String) -> Self {
        var v = self; v.errorMessage = message; return v
    }
    
    /// 텍스트 필드 내부의 패딩을 설정합니다.
    ///
    /// - Parameter insets: 내부 패딩 값
    @discardableResult
    func setupPadding(_ insets: EdgeInsets) -> Self {
        var v = self; v.contentPadding = insets; return v
    }
    
    /// 키보드 타입과 리턴 버튼 동작을 설정합니다.
    ///
    /// - Parameters:
    ///   - type: 키보드 타입 (`.default`, `.numberPad` 등)
    ///   - submit: 리턴 키 타입 (`.next`, `.done` 등)
    ///   - onSubmit: 리턴 키를 눌렀을 때 실행할 액션
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
    
    /// 텍스트 필드의 높이를 설정합니다.
    ///
    /// - Parameter height: 설정할 높이 값
    /// - Note: nil을 전달하면 기본 높이(에러 상태: 104, 일반 상태: 82)를 사용합니다.
    @discardableResult
    func setupHeight(_ height: CGFloat?) -> Self {
        var v = self; v.height = height; return v
    }
    
    /// 텍스트 필드 배경색을 설정합니다.
    /// - Parameter color: 적용할 배경색 (`.mainAlternative`가 기본값)
    @discardableResult
    func setupBackgroundColor(_ color: Color = .mainAlternative) -> Self {
        var v = self; v.backgroundColor = color; return v
    }
}

// #Preview("DWTextField States") {
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
// }
