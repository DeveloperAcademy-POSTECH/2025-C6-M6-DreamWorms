//
//  CaseAddScrollForm.swift
//  SUSA24-iOS
//
//  Created by mini on 11/2/25.
//

import SwiftUI

struct CaseAddScrollForm<Field: Hashable>: View {
    @State private var scrollID: Field?
    @State private var visibleCount: Int = 1

    @Binding var caseName: String
    @Binding var caseNumber: String
    @Binding var suspectName: String
    @Binding var crime: String
    @Binding var suspectPhoneNumber: String
    @Binding var nextTrigger: Field?
    
    let isEditMode: Bool
    let focus: FocusState<Field?>.Binding
    
    let nameField: Field
    let numberField: Field
    let suspectField: Field
    let phoneField: Field
    let crimeField: Field
    
    /// 아래에서부터 위로 쌓이는 순서
    private var orderedFields: [Field] {
        [nameField, numberField, suspectField, crimeField, phoneField]
    }
    
    /// 해당 필드를 현재 visibleCount에서 노출할지 여부
    private func isVisible(_ field: Field) -> Bool {
        if isEditMode { return true } // 수정 모드면 항상 모든 필드가 보여야함!
        guard let index = orderedFields.firstIndex(of: field) else { return false }
        return index < visibleCount
    }
    
    /// current 이후의 다음 필드를 1개 노출 + 포커스 + 스크롤
    private func revealNext(after current: Field) {
        guard !isEditMode else { return } // 수정 모드에서는 reveal 애니메이션 동작하지 않도록
        guard
            let index = orderedFields.firstIndex(of: current),
            index + 1 < orderedFields.count
        else { return }
        
        guard visibleCount == index + 1 else { return }
        
        let next = orderedFields[index + 1]
        
        withAnimation(.snappy(duration: 0.25)) {
            visibleCount = index + 2
            scrollID = next
            focus.wrappedValue = next
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isVisible(phoneField) {
                    DWTextField(
                        text: $suspectPhoneNumber,
                        field: phoneField,
                        externalFocus: focus,
                        title: String(localized: .caseAddSuspectPhoneNumber),
                        placeholder: String(localized: .placeholderSuspectPhoneNumber)
                    )
                    .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                    .setupKeyboard(.phonePad, submit: .done)
                    .id(phoneField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if isVisible(crimeField) {
                    DWTextField(
                        text: $crime,
                        field: crimeField,
                        externalFocus: focus,
                        title: String(localized: .caseAddCrime),
                        placeholder: String(localized: .placeholderCrime)
                    )
                    .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                    .setupKeyboard(.default, submit: .next) {
                        revealNext(after: crimeField)
                    }
                    .id(crimeField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if isVisible(suspectField) {
                    DWTextField(
                        text: $suspectName,
                        field: suspectField,
                        externalFocus: focus,
                        title: String(localized: .caseAddSuspectName),
                        placeholder: String(localized: .placeholderSuspectName)
                    )
                    .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                    .setupKeyboard(.default, submit: .next) {
                        revealNext(after: suspectField)
                    }
                    .id(suspectField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if isVisible(numberField) {
                    DWTextField(
                        text: $caseNumber,
                        field: numberField,
                        externalFocus: focus,
                        title: String(localized: .caseAddCaseNumber),
                        placeholder: String(localized: .placeholderCaseNumber)
                    )
                    .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                    .setupKeyboard(.default, submit: .next) {
                        revealNext(after: numberField)
                    }
                    .id(numberField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if isVisible(nameField) {
                    DWTextField(
                        text: $caseName,
                        field: nameField,
                        externalFocus: focus,
                        title: String(localized: .caseAddCaseName),
                        placeholder: String(localized: .placeholderCaseName)
                    )
                    .setupErrorMessage(String(localized: .textFieldEmptyErrorMessage))
                    .setupKeyboard(.default, submit: .next) {
                        revealNext(after: nameField)
                    }
                    .id(nameField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
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
        .onChange(of: nextTrigger) { _, newTrigger in
            guard let newTrigger else { return }
            revealNext(after: newTrigger)
            
            Task { @MainActor in
                nextTrigger = nil
            }
        }
        .task {
            if isEditMode {
                // 수정 모드: 5개 필드 전부 한 번에 노출
                visibleCount = orderedFields.count
                scrollID = nameField
            } else {
                // 신규 모드: 아래에서부터 하나씩 열리는 애니메이션 유지
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(.snappy(duration: 0.25)) {
                    scrollID = nameField
                    focus.wrappedValue = nameField
                }
            }
        }
    }
}
