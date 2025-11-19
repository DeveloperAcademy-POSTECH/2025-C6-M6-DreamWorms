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
    
    /// 아래 폼에 "다음" 버튼이 눌렸을 때, 어떤 필드 기준으로 다음을 열지 전달하는 트리거
    @State private var nextTrigger: Field? = nil
    
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
                    nextTrigger: $nextTrigger,
                    isEditMode: store.state.isEditMode,
                    focus: $focus,
                    nameField: .name,
                    numberField: .number,
                    suspectField: .suspect,
                    phoneField: .phone,
                    crimeField: .crime
                )
                .scrollIndicators(.hidden)
                .padding(.bottom, 8)
                
                // 추가하기 버튼
                DWButton(
                    isEnabled: .constant(isPrimaryButtonEnabled),
                    title: focus == .phone || store.state.isFormComplete
                        ? String(localized: .buttonAddCase)
                        : String(localized: .next)
                ) {
                    handlePrimaryButtonTap()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .fullScreenCover(isPresented: $showPhotoPicker) {
            FullScreenPhotoPicker(isPresented: $showPhotoPicker) { image, data in
                selectedImage = Image(uiImage: image)
                store.send(.setProfileImage(data))
            }
            .ignoresSafeArea()
        }
        .task { store.send(.onAppear) }
        .onChange(of: store.state.existingProfileImagePath) { _, newPath in
            guard store.state.isEditMode,
                  let newPath,
                  let uiImage = ImageFileStorage.loadProfileImage(from: newPath)
            else { return }
            
            selectedImage = Image(uiImage: uiImage)
        }
    }
}

// MARK: - Extension Methods

extension CaseAddView {}

// MARK: - Private Extension Methods

private extension CaseAddView {
    /// 현재 포커스된 필드에 대해 "버튼을 활성화할 수 있는지" 계산
    var isPrimaryButtonEnabled: Bool {
        if store.state.isEditMode {
            return store.state.isFormComplete
        }
        guard let focus else { return store.state.isFormComplete }
        return isFieldFilled(focus)
    }
    
    /// 특정 필드가 채워져 있는지 체크
    func isFieldFilled(_ field: Field) -> Bool {
        switch field {
        case .name:
            !store.state.caseName.isEmpty
        case .number:
            !store.state.caseName.isEmpty
                && !store.state.caseNumber.isEmpty
        case .suspect:
            !store.state.caseName.isEmpty
                && !store.state.caseNumber.isEmpty
                && !store.state.suspectName.isEmpty
        case .crime:
            !store.state.caseName.isEmpty
                && !store.state.caseNumber.isEmpty
                && !store.state.suspectName.isEmpty
                && !store.state.crime.isEmpty
        case .phone:
            !store.state.caseName.isEmpty
                && !store.state.caseNumber.isEmpty
                && !store.state.suspectName.isEmpty
                && !store.state.crime.isEmpty
                && !store.state.suspectPhoneNumber.isEmpty
        }
    }
    
    /// 폼 전체에서 "비어 있는 첫 번째 필드" 찾기 (필요시 사용)
    func firstEmptyField() -> Field? {
        if store.state.caseName.isEmpty { return .name }
        if store.state.caseNumber.isEmpty { return .number }
        if store.state.suspectName.isEmpty { return .suspect }
        if store.state.crime.isEmpty { return .crime }
        if store.state.suspectPhoneNumber.isEmpty { return .phone }
        return nil
    }
    
    /// 메인 버튼 탭 시 동작
    func handlePrimaryButtonTap() {
        if focus == .phone || store.state.isFormComplete {
            guard store.state.isFormComplete else { return }
            store.send(.addCaseButtonTapped)
            coordinator.pop()
        } else {
            if let current = focus {
                nextTrigger = current
            } else {
                if let empty = firstEmptyField() {
                    focus = empty
                    nextTrigger = empty
                }
            }
        }
    }
}

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
