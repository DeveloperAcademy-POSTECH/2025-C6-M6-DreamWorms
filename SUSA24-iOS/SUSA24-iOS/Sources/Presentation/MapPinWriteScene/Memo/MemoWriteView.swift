//
//  MemoWriteView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/13/25.
//

import SwiftUI

/// 형사 노트 작성/수정 화면
struct MemoWriteView: View {
    let existingNote: String?
    let onSave: (String?) -> Void
    let onCancel: () -> Void
    
    @State private var noteText: String = ""
    @State private var showDeleteConfirmation: Bool = false
    
    @FocusState private var isTextEditorFocused: Bool
    
    private var hasNote: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            Color(.labelAssistive)
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 0) {
                MemoWriteHeader(
                    isSaveEnabled: hasNote,
                    onCloseTapped: {
                        hideKeyboard()
                        onCancel()
                    },
                    onSaveTapped: saveNote
                )
                .padding(.top, 16)
                .padding(.bottom, 28)
                
                // MARK: - TextEditor
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                    
                    TextEditor(text: $noteText)
                        .focused($isTextEditorFocused)
                        .font(.bodyRegular14)
                        .foregroundStyle(.labelNormal)
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if noteText.isEmpty {
                        Text(String(localized: .memoWritePlaceHolder))
                            .font(.bodyRegular14)
                            .foregroundStyle(.labelAlternative)
                            .padding(20)
                    }
                }
                .frame(height: 300)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // MARK: - Delete Button

                if existingNote != nil {
                    Button(action: {
                        hideKeyboard()
                        showDeleteConfirmation = true
                    }) {
                        ZStack {
                            HStack {
                                Image(.delete)
                                    .renderingMode(.template)
                                    .foregroundStyle(.pointRed1)
                                    .frame(width: 21, height: 21, alignment: .center)
                                    .padding(.leading, 24)
                                
                                Spacer()
                            }
                            
                            Text(String(localized: .memoDeleteTitle))
                                .font(.titleSemiBold16)
                                .foregroundStyle(.pointRed1)
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(.pointRed1.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .alert(String(localized: .memoDeleteTitle), isPresented: $showDeleteConfirmation) {
            Button(String(localized: .memoDeleteConfirm), role: .destructive) {
                deleteNote()
            }
            Button(String(localized: .cancelDefault), role: .cancel) {}
        } message: {
            Text(String(localized: .memoDeleteMessage))
        }
        .onAppear {
            noteText = existingNote ?? ""

            Task {
                try? await Task.sleep(nanoseconds: 450_000_000)
                await MainActor.run {
                    isTextEditorFocused = true
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private func saveNote() {
        hideKeyboard()
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(trimmed.isEmpty ? nil : trimmed)
    }
    
    private func deleteNote() {
        hideKeyboard()
        onSave(nil)
    }
}

// MARK: - Preview

//
// #Preview("새 노트 작성") {
//    MemoWriteView(
//        existingNote: nil,
//        onSave: { _ in },
//        onCancel: {}
//    )
// }
//
// #Preview("노트 수정") {
//    MemoWriteView(
//        existingNote: "CCTV 영상으로 판단했을 때 두 사람이 다툰 것으로 보임. 진술과 일치하지 않은 행동을 보이는 내용을 포착. 김호랭 형사에게 영상전달, 맘스터치 매장 직원 증언으로 단골이라고 함.",
//        onSave: { _ in },
//        onCancel: {}
//    )
// }
