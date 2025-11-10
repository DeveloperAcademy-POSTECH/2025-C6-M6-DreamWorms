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
        var caseName: String = ""
        var caseNumber: String = ""
        var suspectName: String = ""
        var suspectPhoneNumber: String = ""
        var crime: String = ""
        var suspectProfileImage: Data?
        var isFormComplete: Bool {
            [caseName, caseNumber, suspectName, suspectPhoneNumber, crime]
                .allSatisfy { !$0.isEmpty }
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case updateCaseName(String)
        case updateCaseNumber(String)
        case updateSuspectName(String)
        case updateSuspectPhoneNumber(String)
        case updateCrimeType(String)
        case setProfileImage(Data?)
        case addCaseButtonTapped
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .updateCaseName(name):
            state.caseName = name; return .none
        case let .updateCaseNumber(number):
            state.caseNumber = number; return .none
        case let .updateSuspectName(name):
            state.suspectName = name; return .none
        case let .updateSuspectPhoneNumber(phoneNumber):
            state.suspectPhoneNumber = phoneNumber; return .none
        case let .updateCrimeType(name):
            state.crime = name; return .none
        case let .setProfileImage(image):
            state.suspectProfileImage = image; return .none
        case .addCaseButtonTapped:
            let model = Case(
                id: UUID(),
                number: state.caseNumber,
                name: state.caseName,
                crime: state.crime,
                suspect: state.suspectName,
                // 객체를 만드는 부분에서는 nil로 일단 생성합니다. 이미지 저장은 Repository에서 처리하므로!
                suspectProfileImage: nil
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
                    return .none
                }
            }
        }
    }
}
