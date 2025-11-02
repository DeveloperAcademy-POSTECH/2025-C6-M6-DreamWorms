//
//  CaseAddScrollForm.swift
//  SUSA24-iOS
//
//  Created by mini on 11/2/25.
//

import SwiftUI

struct CaseAddScrollForm<Field: Hashable>: View {
    @Binding var caseName: String
    @Binding var caseNumber: String
    @Binding var suspectName: String
    @Binding var crime: String

    let focus: FocusState<Field?>.Binding
    
    let nameField: Field
    let numberField: Field
    let suspectField: Field
    let crimeField: Field

    var body: some View {
        VStack(spacing: 20) {
            
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
                focus.wrappedValue = crimeField
            }

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
        }
        .padding(.horizontal, 20)
    }
}
