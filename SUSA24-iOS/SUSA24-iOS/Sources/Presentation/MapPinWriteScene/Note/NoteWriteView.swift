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
            Color(.sheetBackground)
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
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                    
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
                            .padding(.horizontal, 21)
                            .padding(.top, 24)
                            .allowsHitTesting(false)
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
                                    .font(.titleSemiBold18)
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
                        .cornerRadius(26)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom)
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
