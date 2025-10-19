//
//  CaseAddView.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftData
import SwiftUI

struct CaseAddView: View {
    @EnvironmentObject
    private var coordinator: AppCoordinator
    
    @Environment(\.modelContext)
    private var context

    @State private var name: String = ""
    @State private var number: String = ""
    @State private var suspectName: String = ""

    enum Field: Hashable { case name, number, suspect }
    @FocusState private var focused: Field?

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !number.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !suspectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollViewReader { _ in
            VStack(alignment: .leading, spacing: 0) {
                CaseAddHeader(
                    onClose: { coordinator.pop() }
                )

                CaseAddScrollForm(
                    name: $name,
                    number: $number,
                    suspectName: $suspectName,
                    focused: $focused,
                    onScanTap: {
                        // TODO: - 추후 스캔 기능 연결
                    }
                )
                .scrollDisabled(true)
                .scrollIndicators(.hidden)
                
                Spacer()

                DWButton(
                    title: String(localized: .btnAdd),
                    isEnabled: Binding(get: { canAdd }, set: { _ in })
                ) {
                    saveAndClose()
                }
                .padding(.top, 8)
            }
            .navigationBarBackButtonHidden()
            .task { focused = .name }
        }
    }

    private func saveAndClose() {
        let newCase = Case(name: name, number: number, suspectName: suspectName)
        context.insert(newCase)
        newCase.setAsCurrentCase() // NOTE: 삭제 예정
        try? context.save()
        coordinator.pop()
    }
}

#Preview {
    CaseAddView()
}
