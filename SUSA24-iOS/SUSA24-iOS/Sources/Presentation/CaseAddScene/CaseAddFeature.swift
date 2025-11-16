//
//  CaseAddFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI

struct CaseAddFeature: DWReducer {
    private let repository: CaseRepositoryProtocol
    init(repository: CaseRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        /// nil이면 신규 생성, 값이 있으면 편집 모드
        var editingCaseId: UUID?
        var isEditMode: Bool { editingCaseId != nil }

        var caseName: String = ""
        var caseNumber: String = ""
        var suspectName: String = ""
        var crime: String = ""
        var suspectPhoneNumber: String = ""
        var suspectProfileImage: Data?
        
        /// 수정 모드에서 기존에 저장돼 있던 이미지 경로(있을 수도 있고, 없을 수도 있음)
        var existingProfileImagePath: String?
        
        var isFormComplete: Bool {
            [caseName, caseNumber, suspectName, suspectPhoneNumber, crime]
                .allSatisfy { !$0.isEmpty }
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear
        case setExistingCase(Case, phoneNumber: String?, profileImagePath: String?)
        case updateCaseName(String)
        case updateCaseNumber(String)
        case updateSuspectName(String)
        case updateCrimeType(String)
        case updateSuspectPhoneNumber(String)
        case setProfileImage(Data?)
        case addCaseButtonTapped
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            guard let id = state.editingCaseId else { return .none }
            return .task {
                do {
                    let result = try await repository.fetchCaseForEdit(for: id)
                    if let caseModel = result.case {
                        return .setExistingCase(
                            caseModel,
                            phoneNumber: result.phoneNumber,
                            profileImagePath: result.profileImagePath
                        )
                    } else {
                        return .none
                    }
                } catch {
                    return .none
                }
            }
            
        case let .setExistingCase(caseModel, phoneNumber, profileImagePath):
            state.caseName = caseModel.name
            state.caseNumber = caseModel.number
            state.suspectName = caseModel.suspect
            state.crime = caseModel.crime
            state.suspectPhoneNumber = phoneNumber ?? ""
            // 이미지 Data는 실제로 유저가 수정할 때만 setProfileImage로 들어오게 함으로 여기서는 경로!
            state.existingProfileImagePath = profileImagePath
            return .none
            
        case let .updateCaseName(name):
            state.caseName = name; return .none
            
        case let .updateCaseNumber(number):
            state.caseNumber = number; return .none
            
        case let .updateSuspectName(name):
            state.suspectName = name; return .none
            
        case let .updateCrimeType(name):
            state.crime = name; return .none
            
        case let .updateSuspectPhoneNumber(number):
            state.suspectPhoneNumber = number; return .none
            
        case let .setProfileImage(image):
            state.suspectProfileImage = image; return .none
            
        case .addCaseButtonTapped:
            return handleAddOrUpdateCase(state: state)
        }
    }
}

private extension CaseAddFeature {
    /// add / edit 모드를 구분해서 각각 처리하는 진입 메서드
    func handleAddOrUpdateCase(state: State) -> DWEffect<CaseAddFeature.Action> {
        if state.isEditMode {
            handleEditCase(state: state)
        } else {
            handleCreateCase(state: state)
        }
    }
    
    /// 수정 모드 처리
    func handleEditCase(state: State) -> DWEffect<CaseAddFeature.Action> {
        guard let editingId = state.editingCaseId else {
            // 이 경우는 로직 상 거의 없겠지만, 방어적으로 .none
            return .none
        }
        
        let model = Case(
            id: editingId,
            number: state.caseNumber,
            name: state.caseName,
            crime: state.crime,
            suspect: state.suspectName,
            // 기존 이미지는 profileImagePath로 유지, 새 데이터가 있으면 repository에서 교체
            suspectProfileImage: state.existingProfileImagePath
        )
        
        let phoneNumber = state.suspectPhoneNumber.isEmpty ? nil : state.suspectPhoneNumber
        let imageData = state.suspectProfileImage // nil이면 기존 이미지 유지
        
        return .task {
            do {
                try await repository.updateCase(
                    model: model,
                    imageData: imageData,
                    phoneNumber: phoneNumber
                )
                return .none
            } catch {
                // TODO: - 에러 핸들링 액션 필요하다면 여기에 추가
                return .none
            }
        }
    }
    
    /// 신규 생성 모드 처리
    func handleCreateCase(state: State) -> DWEffect<CaseAddFeature.Action> {
        let model = Case(
            id: UUID(),
            number: state.caseNumber,
            name: state.caseName,
            crime: state.crime,
            suspect: state.suspectName,
            suspectProfileImage: nil // 최초 생성 시 경로는 repository에서 저장
        )
        
        let imageData = state.suspectProfileImage
        let phoneNumber = state.suspectPhoneNumber.isEmpty ? nil : state.suspectPhoneNumber
        
        return .task {
            do {
                try await repository.createCase(
                    model: model,
                    imageData: imageData,
                    phoneNumber: phoneNumber
                )
                return .none
            } catch {
                // TODO: - 에러 핸들링 액션 필요하다면 여기에 추가
                return .none
            }
        }
    }
}
