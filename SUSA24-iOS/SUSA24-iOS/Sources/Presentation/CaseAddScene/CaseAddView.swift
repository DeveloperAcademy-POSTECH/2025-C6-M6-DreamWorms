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
    
    enum Field: Hashable { case name, number, suspect, crime }
    
    @State private var showPhotoDialog: Bool = false
    @FocusState private var focus: Field?

    // MARK: - View
    
    var body: some View {
        VStack(spacing: 32) {
            SuspectImageSelector(
                image: .constant(nil),
                onTap: { showPhotoDialog = true }
            )
            .confirmationDialog("", isPresented: $showPhotoDialog) {
                Button(
                    String(localized: .caseAddDeleteImage),
                    role: .destructive
                ) {
                    // 사진 삭제
                }
                
                Button(String(localized: .caseAddSelectImage)) {
                    // 앨범으로 넘어가기
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 33)
            
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
                focus: $focus,
                nameField: .name,
                numberField: .number,
                suspectField: .suspect,
                crimeField: .crime
            )
            .scrollIndicators(.hidden)
                                    
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
}

// MARK: - Extension Methods

extension CaseAddView {}

// MARK: - Private Extension Methods

private extension CaseAddView {}

// MARK: - Preview

#Preview {
    CaseAddView(
        store: DWStore(
            initialState: CaseAddFeature.State(),
            reducer: CaseAddFeature(repository: MockCaseRepository())
        )
    )
    .environment(AppCoordinator())
}

private struct MockCaseRepository: CaseRepositoryProtocol {
    func fetchCases() async throws -> [Case] { [] }
    func deleteCase(id: UUID) async throws {}
    func createCase(model: Case) async throws {}
}
