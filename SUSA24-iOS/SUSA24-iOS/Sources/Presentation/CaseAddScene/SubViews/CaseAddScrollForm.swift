//
//  CaseAddScrollForm.swift
//  SUSA24-iOS
//
//  Created by mini on 11/2/25.
//

import SwiftUI

struct CaseAddScrollForm<Field: Hashable>: View {
    @State private var scrollID: Field?

    @Binding var caseName: String
    @Binding var caseNumber: String
    @Binding var suspectName: String
    @Binding var suspectPhoneNumber: String
    @Binding var crime: String

    let focus: FocusState<Field?>.Binding

    let nameField: Field
    let numberField: Field
    let suspectField: Field
    let phoneField: Field
    let crimeField: Field
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 사건명
                DWTextField(
                    text: $caseName,
                    field: nameField,
                    externalFocus: focus,
                    title: String(localized: .caseAddCaseName),
                    placeholder: String(localized: .placeholderCaseName)
                )
                .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                .setupKeyboard(.default, submit: .next) {
                    focus.wrappedValue = numberField
                }
                .id(nameField)
                
                // 사건번호
                DWTextField(
                    text: $caseNumber,
                    field: numberField,
                    externalFocus: focus,
                    title: String(localized: .caseAddCaseNumber),
                    placeholder: String(localized: .placeholderCaseNumber)
                )
                .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                .setupKeyboard(.default, submit: .next) {
                    focus.wrappedValue = suspectField
                }
                .id(numberField)
                
                // 피의자명
                DWTextField(
                    text: $suspectName,
                    field: suspectField,
                    externalFocus: focus,
                    title: String(localized: .caseAddSuspectName),
                    placeholder: String(localized: .placeholderSuspectName)
                )
                .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                .setupKeyboard(.default, submit: .next) {
                    focus.wrappedValue = phoneField
                }
                .id(suspectField)

                // 피의자 전화번호
                DWTextField(
                    text: $suspectPhoneNumber,
                    field: phoneField,
                    externalFocus: focus,
                    title: "피의자 전화번호",
                    placeholder: "010-1234-5678"
                )
                .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                .setupKeyboard(.phonePad, submit: .next) {
                    focus.wrappedValue = crimeField
                }
                .id(phoneField)

                // 범죄유형
                DWTextField(
                    text: $crime,
                    field: crimeField,
                    externalFocus: focus,
                    title: String(localized: .caseAddCrime),
                    placeholder: String(localized: .placeholderCrime)
                )
                .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                .setupKeyboard(.default, submit: .done)
                .id(crimeField)
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.bottom, 20)
        }
        .scrollPosition(id: $scrollID)
        .scrollDisabled(true)
        .onChange(of: focus.wrappedValue) { _, newFocus in
            guard let newFocus else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(80))
                withAnimation(.snappy(duration: 0.25)) {
                    scrollID = newFocus
                }
            }
        }
    }
}
