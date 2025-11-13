//
//  CaseAddView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct CaseAddView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var store: DWStore<CaseAddFeature>
    
    // MARK: - Properties
    
    enum Field: Hashable { case name, number, suspect, phone, crime }
    
    @FocusState private var focus: Field?
    @State private var showPhotoDialog: Bool = false
    @State private var showPhotoPicker = false
    @State private var selectedImage: Image? = nil
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture { focus = nil }
            
            VStack(spacing: 0) {
                // 상단 프로필 이미지
                SuspectImageSelector(
                    image: $selectedImage,
                    onTap: {
                        if selectedImage == nil {
                            focus = nil
                            showPhotoPicker = true
                        } else {
                            showPhotoDialog = true
                        }
                    }
                )
                .confirmationDialog("", isPresented: $showPhotoDialog) {
                    Button(
                        String(localized: .caseAddDeleteImage),
                        role: .destructive
                    ) {
                        selectedImage = nil
                        store.send(.setProfileImage(nil))
                    }
                    
                    Button(String(localized: .caseAddSelectImage)) {
                        focus = nil
                        showPhotoPicker = true
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 33)
                
                // 텍스트필드 모음
                CaseAddScrollForm<Field>(
                    caseName: Binding(
                        get: { store.state.caseName },
                        set: { store.send(.updateCaseName($0)) }
                    ),
                    caseNumber: Binding(
                        get: { store.state.caseNumber },
                        set: { store.send(.updateCaseNumber($0)) }
                    ),
                    suspectName: Binding(
                        get: { store.state.suspectName },
                        set: { store.send(.updateSuspectName($0)) }
                    ),
                    crime: Binding(
                        get: { store.state.crime },
                        set: { store.send(.updateCrimeType($0)) }
                    ),
                    suspectPhoneNumber: Binding(
                        get: { store.state.suspectPhoneNumber },
                        set: { store.send(.updateSuspectPhoneNumber($0)) }
                    ),
                    focus: $focus,
                    nameField: .name,
                    numberField: .number,
                    suspectField: .suspect,
                    phoneField: .phone,
                    crimeField: .crime
                )
                .scrollIndicators(.hidden)
                .padding(.bottom, 20)
                
                // 추가하기 버튼
                DWButton(
                    isEnabled: .constant(store.state.isFormComplete),
                    title: String(localized: .buttonAddCase)
                ) {
                    store.send(.addCaseButtonTapped)
                    coordinator.pop()
                }
                .padding(.horizontal, 16)
            }
        }
        .fullScreenCover(isPresented: $showPhotoPicker) {
            FullScreenPhotoPicker(isPresented: $showPhotoPicker) { image, data in
                selectedImage = Image(uiImage: image)
                store.send(.setProfileImage(data))
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Extension Methods

extension CaseAddView {}

// MARK: - Private Extension Methods

private extension CaseAddView {}

// MARK: - Preview

// #Preview {
//    CaseAddView(
//        store: DWStore(
//            initialState: CaseAddFeature.State(),
//            reducer: CaseAddFeature(repository: MockCaseRepository())
//        )
//    )
//    .environment(AppCoordinator())
// }
