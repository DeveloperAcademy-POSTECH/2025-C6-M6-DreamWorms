//
//  CaseListFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import CoreData
import SwiftUI

enum CaseListPickerTab: CaseIterable {
    case allCase, shareCase
    var title: String {
        switch self {
        case .allCase: String(localized: .caseListAllCasePicker)
        case .shareCase: String(localized: .caseListShareCasePicker)
        }
    }
}

struct CaseListFeature: DWReducer {
    private let repository: CaseRepositoryProtocol
    init(repository: CaseRepositoryProtocol) { self.repository = repository }
    
    // MARK: - State
    
    struct State: DWState {
        var selectedTab: CaseListPickerTab = .allCase
        var cases: [Case] = []
        
        // TODO: 지금 로직에서는 해당 부분 적용 x, 추후 공유 기능 추가되면 수정
        var shareCases: [Case] = []
        
        // MARK: - 기지국 데이터 추가 관련 상태
        
        var targetCaseIdForCellLog: UUID?
        var isShowingOverwriteAlert: Bool = false
        var isShowingSuccessAlert: Bool = false
        
        // MARK: - 핀 데이터 추가 관련 상태
        
        var targetCaseIdForPinData: UUID?
        var isShowingPinDataOverwriteAlert: Bool = false
        var isShowingPinDataSuccessAlert: Bool = false
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        case onAppear
        case loadCases([Case])
        case setTab(CaseListPickerTab)
        case deleteTapped(item: Case)
        
        // MARK: - 기지국 데이터 추가
        
        case cellLogMenuTapped(caseID: UUID)
        case cellLogCheckCompleted(caseID: UUID, hasExisting: Bool)
        case addCellLog(caseID: UUID, overwrite: Bool)
        case cellLogAdded(Result<Void, Error>)
        
        // MARK: - 핀 데이터 추가
        
        case pinDataMenuTapped(caseID: UUID)
        case pinDataCheckCompleted(caseID: UUID, hasExisting: Bool)
        case addPinData(caseID: UUID, overwrite: Bool)
        case pinDataAdded(Result<Void, Error>)
        
        // MARK: - Alert 종료
        
        case dismissOverwriteAlert
        case dismissSuccessAlert
        case dismissPinDataOverwriteAlert
        case dismissPinDataSuccessAlert
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            return .task { [repository] in
                do {
                    let items = try await repository.fetchCases()
                    return .loadCases(items)
                } catch {
                    return .none
                }
            }
            
        case let .loadCases(cases):
            state.cases = cases
            return .none
            
        case let .setTab(tab):
            state.selectedTab = tab
            return .none
        
        case let .deleteTapped(item):
            return .task { [repository] in
                do {
                    try await repository.deleteCase(id: item.id)
                    
                    let items = try await repository.fetchCases()
                    return .loadCases(items)
                    
                } catch {
                    return .none
                }
            }
        
        // ===============================================================
        // MARK: - 기지국 데이터 추가

        // ===============================================================
        case let .cellLogMenuTapped(caseID):
            return .task {
                do {
                    let context = await PersistenceController.shared.container.viewContext
                    let locationRepo = await LocationRepository(context: context)
                    
                    let existing = try await locationRepo.fetchNoCellLocations(
                        caseId: caseID,
                        locationType: [2]
                    )
                    
                    return .cellLogCheckCompleted(
                        caseID: caseID,
                        hasExisting: !existing.isEmpty
                    )
                    
                } catch {
                    return .cellLogCheckCompleted(caseID: caseID, hasExisting: false)
                }
            }
            
        case let .cellLogCheckCompleted(caseID, hasExisting):
            state.targetCaseIdForCellLog = caseID
            
            if hasExisting {
                state.isShowingOverwriteAlert = true
                return .none
            } else {
                return .task {
                    .addCellLog(caseID: caseID, overwrite: false)
                }
            }
        
        case let .addCellLog(caseID, overwrite):
            state.isShowingOverwriteAlert = false
            
            return .task {
                do {
                    let context = await PersistenceController.shared.container.viewContext
                    let locationRepo = await LocationRepository(context: context)
                    
                    // 기존 기지국 삭제
                    if overwrite {
                        let existing = try await locationRepo.fetchNoCellLocations(
                            caseId: caseID,
                            locationType: [2]
                        )
                        
                        for loc in existing {
                            try await locationRepo.deleteLocation(id: loc.id)
                        }
                    }
                    
                    let newLocations = try await LocationMockLoader.loadCellLogSampleWithGeocode()
                    
                    try await locationRepo.createLocations(data: newLocations, caseId: caseID)
                    
                    return .cellLogAdded(.success(()))
                    
                } catch {
                    return .cellLogAdded(.failure(error))
                }
            }
        
        case let .cellLogAdded(result):
            switch result {
            case .success:
                state.isShowingSuccessAlert = true
            case let .failure(err):
                print(" 핀 mock 데이터 저장 실패: \(err)")
            }
            
            return .task { [repository] in
                let items = try? await repository.fetchCases()
                return .loadCases(items ?? [])
            }
        
        // ===============================================================
        // MARK: - 핀 데이터 추가

        // ===============================================================
        case let .pinDataMenuTapped(caseID):
            return .task {
                do {
                    let context = await PersistenceController.shared.container.viewContext
                    let locationRepo = await LocationRepository(context: context)
                    
                    // locationType 0, 1, 3인 핀 데이터 확인
                    let existing = try await locationRepo.fetchNoCellLocations(
                        caseId: caseID,
                        locationType: [0, 1, 3]
                    )
                    
                    return .pinDataCheckCompleted(
                        caseID: caseID,
                        hasExisting: !existing.isEmpty
                    )
                    
                } catch {
                    return .pinDataCheckCompleted(caseID: caseID, hasExisting: false)
                }
            }
            
        case let .pinDataCheckCompleted(caseID, hasExisting):
            state.targetCaseIdForPinData = caseID
            
            if hasExisting {
                state.isShowingPinDataOverwriteAlert = true
                return .none
            } else {
                return .task {
                    .addPinData(caseID: caseID, overwrite: false)
                }
            }
        
        case let .addPinData(caseID, overwrite):
            state.isShowingPinDataOverwriteAlert = false
            
            return .task {
                do {
                    let context = await PersistenceController.shared.container.viewContext
                    let locationRepo = await LocationRepository(context: context)
                    
                    // 기존 핀 데이터 삭제
                    if overwrite {
                        let existing = try await locationRepo.fetchNoCellLocations(
                            caseId: caseID,
                            locationType: [0, 1, 3]
                        )
                        for loc in existing {
                            try await locationRepo.deleteLocation(id: loc.id)
                        }
                    }
                    
                    let newLocations = try await LocationMockLoader.loadPinDataSample()
                    
                    try await locationRepo.createLocations(data: newLocations, caseId: caseID)
                    
                    return .pinDataAdded(.success(()))
                    
                } catch {
                    print("addPinData 실패: \(error)")
                    return .pinDataAdded(.failure(error))
                }
            }
        
        case let .pinDataAdded(result):
            switch result {
            case .success:
                state.isShowingPinDataSuccessAlert = true
            case let .failure(err):
                print("핀 mock 데이터 저장 실패: \(err)")
            }
            
            return .task { [repository] in
                let items = try? await repository.fetchCases()
                return .loadCases(items ?? [])
            }
        
        case .dismissOverwriteAlert:
            state.isShowingOverwriteAlert = false
            return .none
        
        case .dismissSuccessAlert:
            state.isShowingSuccessAlert = false
            return .none
        
        case .dismissPinDataOverwriteAlert:
            state.isShowingPinDataOverwriteAlert = false
            return .none
        
        case .dismissPinDataSuccessAlert:
            state.isShowingPinDataSuccessAlert = false
            return .none
        }
    }
}
