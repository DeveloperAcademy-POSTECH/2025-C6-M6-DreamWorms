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
        var crime: String = ""
        var isFormComplete: Bool {
            [caseName, caseNumber, suspectName, crime]
                .allSatisfy { !$0.isEmpty }
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case updateCaseName(String)
        case updateCaseNumber(String)
        case updateSuspectName(String)
        case updateCrimeType(String)
        case addCaseButtonTapped
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .updateCaseName(let name):
            state.caseName = name; return .none
        case .updateCaseNumber(let number):
            state.caseNumber = number; return .none
        case .updateSuspectName(let name):
            state.suspectName = name; return .none
        case .updateCrimeType(let name):
            state.crime = name; return .none
        case .addCaseButtonTapped:
            let model = Case(
                id: UUID(),
                number: state.caseNumber,
                name: state.caseName,
                crime: state.crime,
                suspect: state.suspectName
            )
            
            return .task {
                do {
                    try await repository.createCase(model: model)
                    return .none
                } catch {
                    return .none
                }
            }
        }
    }
}
