//
//  NoteWriteView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/21/25.
//

import SwiftUI

/// 형사 노트 작성/수정 화면
struct NoteWriteView: View {
    @State private var store: DWStore<NoteWriteFeature>
    @FocusState private var isTextEditorFocused: Bool
    let onCancel: () -> Void
    
    // MARK: - Initializer
    
    init(
        store: DWStore<NoteWriteFeature>,
        onCancel: @escaping () -> Void
    ) {
        self._store = State(initialValue: store)
        self.onCancel = onCancel
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.labelAssistive)
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 0) {
                NoteWriteHeader(
                    isSaveEnabled: store.state.hasNote,
                    onCloseTapped: {
                        hideKeyboard()
                        store.send(.cancelTapped)
                        onCancel()
                    },
                    onSaveTapped: {
                        store.send(.saveTapped)
                    }
                )
                .padding(.top, 16)
                .padding(.bottom, 28)
                
                // MARK: - TextEditor
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                    
                    TextEditor(
                        text: Binding(
                            get: { store.state.noteText },
                            set: { store.send(.updateNoteText($0)) }
                        )
                    )
                    .focused($isTextEditorFocused)
                    .font(.bodyRegular14)
                    .foregroundStyle(.labelNormal)
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if store.state.noteText.isEmpty {
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

                if store.state.existingNote != nil {
                    Button(action: {
                        hideKeyboard()
                        store.send(.deleteTapped)
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
        .alert(
            String(localized: .memoDeleteTitle),
            isPresented: Binding(
                get: { store.state.showDeleteConfirmation },
                set: { if !$0 { store.send(.dismissDeleteAlert) } }
            )
        ) {
            Button(String(localized: .memoDeleteConfirm), role: .destructive) {
                store.send(.confirmDelete)
            }
            Button(String(localized: .cancelDefault), role: .cancel) {
                store.send(.dismissDeleteAlert)
            }
        } message: {
            Text(String(localized: .memoDeleteMessage))
        }
        .task {
            store.send(.onAppear)
            
            // 딜레이 후 포커스 설정
            try? await Task.sleep(nanoseconds: 450_000_000)
            isTextEditorFocused = true
        }
    }
}
