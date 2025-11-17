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
        
        // MARK: - Alert 종료

        case dismissOverwriteAlert
        case dismissSuccessAlert
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        print("🔥 [CaseListFeature] Action received → \(action)")
        
        switch action {
        // ===============================================================
        // MARK: - 기본 Case List 로직

        // ===============================================================
        case .onAppear:
            print("🔥 [CaseListFeature] onAppear → fetchCases 시작")

            return .task { [repository] in
                do {
                    let items = try await repository.fetchCases()
                    print("✅ [CaseListFeature] fetchCases 성공 → \(items.count)개")
                    return .loadCases(items)
                } catch {
                    print("❌ [CaseListFeature] fetchCases 실패: \(error)")
                    return .none
                }
            }
            
        case let .loadCases(cases):
            print("🔥 [CaseListFeature] loadCases → \(cases.count)개 세팅")
            state.cases = cases
            return .none
            
        case let .setTab(tab):
            print("🔥 [CaseListFeature] setTab → \(tab)")
            state.selectedTab = tab
            return .none
        
        case let .deleteTapped(item):
            print("🔥 [CaseListFeature] deleteTapped → \(item.id)")

            return .task { [repository] in
                do {
                    try await repository.deleteCase(id: item.id)
                    print("✅ [CaseListFeature] deleteCase 성공")

                    let items = try await repository.fetchCases()
                    print("🔥 [CaseListFeature] delete 후 fetchCases → \(items.count)개")
                    return .loadCases(items)

                } catch {
                    print("❌ [CaseListFeature] deleteCase 오류: \(error)")
                    return .none
                }
            }
        
        // ===============================================================
        // MARK: - 기지국 데이터 추가

        // ===============================================================
        case let .cellLogMenuTapped(caseID):
            print("🔥 [CaseListFeature] cellLogMenuTapped → caseID: \(caseID)")

            return .task {
                do {
                    let context = await PersistenceController.shared.container.viewContext
                    let locationRepo = await LocationRepository(context: context)
                    
                    let existing = try await locationRepo.fetchNoCellLocations(
                        caseId: caseID,
                        locationType: [2]
                    )

                    print("🔥 [CaseListFeature] 기존 기지국 데이터 개수: \(existing.count)")

                    return .cellLogCheckCompleted(
                        caseID: caseID,
                        hasExisting: !existing.isEmpty
                    )

                } catch {
                    print("❌ [CaseListFeature] 기지국 기존 데이터 조회 실패: \(error)")
                    return .cellLogCheckCompleted(caseID: caseID, hasExisting: false)
                }
            }
        
        case let .cellLogCheckCompleted(caseID, hasExisting):
            print("🔥 [CaseListFeature] cellLogCheckCompleted → hasExisting: \(hasExisting)")

            state.targetCaseIdForCellLog = caseID

            if hasExisting {
                print("⚠️ [CaseListFeature] 기존 데이터 존재 → Overwrite Alert 표시")
                state.isShowingOverwriteAlert = true
                return .none
            } else {
                print("🔥 [CaseListFeature] 기존 데이터 없음 → 바로 addCellLog 실행")
                return .task {
                    .addCellLog(caseID: caseID, overwrite: false)
                }
            }
        
        case let .addCellLog(caseID, overwrite):
            print("🔥 [CaseListFeature] addCellLog → overwrite: \(overwrite)")
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
                        print("🔥 [CaseListFeature] 기존 기지국 삭제 개수: \(existing.count)")
                        for loc in existing {
                            try await locationRepo.deleteLocation(id: loc.id)
                        }
                    }
                    
                    print("🔥 [CaseListFeature] mock + geocode 데이터 로드 시작")
                    let newLocations = try await LocationMockLoader.loadCellLogSampleWithGeocode()
                    print("🔥 [CaseListFeature] mock 로드 완료 → \(newLocations.count)개")

                    print("🔥 [CaseListFeature] createLocations 저장 시작")
                    try await locationRepo.createLocations(data: newLocations, caseId: caseID)
                    print("✅ [CaseListFeature] createLocations 저장 성공")

                    return .cellLogAdded(.success(()))

                } catch {
                    print("❌ [CaseListFeature] addCellLog 실패: \(error)")
                    return .cellLogAdded(.failure(error))
                }
            }
        
        case let .cellLogAdded(result):
            print("🔥 [CaseListFeature] cellLogAdded → \(result)")

            switch result {
            case .success:
                print("✅ [CaseListFeature] 기지국 mock 데이터 저장 성공 → 성공 Alert 표시")
                state.isShowingSuccessAlert = true
            case let .failure(err):
                print("❌ [CaseListFeature] 기지국 mock 데이터 저장 실패: \(err)")
            }
            
            return .task { [repository] in
                let items = try? await repository.fetchCases()
                print("🔥 [CaseListFeature] 저장 후 fetchCases → \(items?.count ?? 0)개")
                return .loadCases(items ?? [])
            }
        
        // ===============================================================
        // MARK: - Alert 닫기 액션

        // ===============================================================
        case .dismissOverwriteAlert:
            print("🔥 [CaseListFeature] dismissOverwriteAlert")
            state.isShowingOverwriteAlert = false
            return .none
        
        case .dismissSuccessAlert:
            print("🔥 [CaseListFeature] dismissSuccessAlert")
            state.isShowingSuccessAlert = false
            return .none
        }
    }
}
