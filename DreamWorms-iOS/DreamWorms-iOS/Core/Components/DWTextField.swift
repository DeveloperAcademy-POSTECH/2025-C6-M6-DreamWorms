//
//  DWTextField.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/18/25.
//

import SwiftUI

struct DWTextField<Field: Hashable>: View {
    @Binding var text: String

    private let title: String
    private let placeholder: String
    
    private var submitLabel: SubmitLabel = .next
    private var onSubmit: (() -> Void)?
    
    private let field: Field
    private let focus: FocusState<Field?>.Binding
    
    init(
        text: Binding<String>,
        title: String,
        placeholder: String = "",
        submitLabel: SubmitLabel = .next,
        onSubmit: (() -> Void)? = nil,
        field: Field,
        focus: FocusState<Field?>.Binding
    ) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.field = field
        self.focus = focus
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.pretendardSemiBold(size: 14))
                .foregroundStyle(focus.wrappedValue == field ? Color.mainBlue : Color.gray8B)

            TextField(placeholder, text: $text)
                .submitLabel(submitLabel)
                .focused(focus, equals: field)
                .onSubmit { onSubmit?() }

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(focus.wrappedValue == field ? Color.mainBlue : Color.gray8B)
                .animation(.easeOut(duration: 0.18), value: focus.wrappedValue == field)
        }
    }
}
