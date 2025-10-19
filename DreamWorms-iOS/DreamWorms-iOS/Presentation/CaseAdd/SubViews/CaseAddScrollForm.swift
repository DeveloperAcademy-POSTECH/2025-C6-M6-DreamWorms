//
//  CaseAddScrollForm.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/19/25.
//

import SwiftUI

struct CaseAddScrollForm: View {
    @Binding var name: String
    @Binding var number: String
    @Binding var suspectName: String

    let focused: FocusState<CaseAddView.Field?>.Binding
    let onScanTap: () -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    DWTextField(
                        text: $name,
                        title: String(localized: .caseAddCaseName),
                        submitLabel: .next,
                        onSubmit: { focused.wrappedValue = .number },
                        field: .name,
                        focus: focused
                    )
                    .id(CaseAddView.Field.name)

                    DWTextField(
                        text: $number,
                        title: String(localized: .caseAddCaseNumber),
                        submitLabel: .next,
                        onSubmit: { focused.wrappedValue = .suspect },
                        field: .number,
                        focus: focused
                    )
                    .id(CaseAddView.Field.number)

                    DWTextField(
                        text: $suspectName,
                        title: String(localized: .caseAddSuspectName),
                        submitLabel: .done,
                        onSubmit: { focused.wrappedValue = nil },
                        field: .suspect,
                        focus: focused
                    )
                    .id(CaseAddView.Field.suspect)

                    Button(action: onScanTap) {
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
            }
            .onChange(of: focused.wrappedValue) { _, target in
                guard let target else { return }
                withAnimation { proxy.scrollTo(target, anchor: .center) }
            }
        }
    }
}
