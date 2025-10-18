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

    private enum Field: Hashable { case name, number, suspect }
    @FocusState private var focused: Field?

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !number.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !suspectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button { coordinator.pop() } label: {
                        Image(.icnClose24)
                            .renderingMode(.template)
                            .foregroundStyle(.gray44)
                            .frame(width: 44, height: 44)
                            .background(.white, in: Circle())
                            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 2)
                    }
                }
                .padding(.top, 10)
                .padding([.bottom, .horizontal], 16)

                HStack {
                    Text(.caseAddTitle)
                        .font(.pretendardSemiBold(size: 24))
                        .foregroundStyle(.black22)
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.bottom, 36)

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        DWTextField(
                            text: $name,
                            title: String(localized: .caseAddCaseName),
                            submitLabel: .next,
                            onSubmit: { focused = .number },
                            field: .name,
                            focus: $focused
                        )
                        .id(Field.name)

                        DWTextField(
                            text: $number,
                            title: String(localized: .caseAddCaseNumber),
                            submitLabel: .next,
                            onSubmit: { focused = .suspect },
                            field: .number,
                            focus: $focused
                        )
                        .id(Field.number)

                        DWTextField(
                            text: $suspectName,
                            title: String(localized: .caseAddSuspectName),
                            submitLabel: .done,
                            onSubmit: { focused = nil },
                            field: .suspect,
                            focus: $focused
                        )
                        .id(Field.suspect)

                        Button {
                            // TODO: - 스캔 기능 추가되면 그때 연결하기
                        } label: {
                            HStack(spacing: 6) {
                                Image(.icnCamera16).renderingMode(.template)
                                Text(.caseAddScanReport)
                                    .font(.pretendardMedium(size: 12))
                            }
                            .foregroundStyle(.gray44)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.grayF2, in: RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    .padding(.horizontal, 16)
                    .onChange(of: focused) { _, target in
                        guard let target else { return }
                        withAnimation {
                            proxy.scrollTo(target, anchor: .center)
                        }
                    }
                }
                .scrollDisabled(true)
                .scrollIndicators(.hidden)
                
                Spacer()

                DWButton(
                    title: String(localized: .btnAdd),
                    isEnabled: canAdd
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
