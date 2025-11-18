//
//  ScanListFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation

/// 스캔 결과 목록 Feature
///
/// ScanLoadFeature에서 분석된 주소 목록을 받아
/// 사용자가 PinCategoryType을 선택하고 CoreData에 저장합니다.
/// 중복 주소 감지 시 덮어쓰기 여부를 확인합니다.
struct ScanListFeature: DWReducer {
    // MARK: - Dependencies

    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - State

    struct State: DWState {
        /// 분석 결과 목록 (Geocode 검증 완료)
        var scanResults: [ScanResult]

        /// 선택된 인덱스
        var selectedIndex: Set<Int> = []

        /// 각 항목의 PinCategoryType 선택 상태
        var typeSelections: [Int: PinCategoryType] = [:]

        /// 저장 중 상태
        var isSaving: Bool = false

        /// 에러 메시지
        var errorMessage: String?

        /// 저장 완료 플래그
        var isSaveCompleted: Bool = false

        /// 중복 Location 확인 Alert 표시 여부
        var showDuplicateAlert: Bool = false

        /// 중복된 주소 (Alert에 표시용)
        var duplicateAddress: String?

        /// 중복 체크를 통과한 Locations (덮어쓰기 확인 후 저장)
        var pendingLocations: [Location] = []

        /// 현재 케이스 ID (저장 시 필요)
        var currentCaseID: UUID?

        /// 지도에 추가 할 것인지 여부
        var canAddPin: Bool {
            guard !selectedIndex.isEmpty else { return false }
            return selectedIndex.allSatisfy { typeSelections[$0] != nil }
        }

        init(scanResults: [ScanResult]) {
            self.scanResults = scanResults
        }
    }

    // MARK: - Action

    enum Action: DWAction {
        // MARK: Selection

        /// 체크박스 토글
        case toggleSelection(index: Int)

        /// PinCategoryType 선택
        case selectType(index: Int, type: PinCategoryType)

        // MARK: Duplicate Check

        /// 중복 Location 확인
        case checkDuplicateLocations(locations: [Location], caseID: UUID)

        /// 중복 발견
        case duplicateFound(address: String, locations: [Location], caseID: UUID)

        /// 중복 없음 → 바로 저장
        case noDuplicatesFound(locations: [Location], caseID: UUID)

        /// 덮어쓰기 확인
        case confirmOverwrite

        /// 덮어쓰기 취소
        case cancelOverwrite

        // MARK: Save

        /// "핀 추가하기" 버튼 탭
        case saveButtonTapped(caseID: UUID)

        /// 실제 저장 실행
        case executeSave(locations: [Location], caseID: UUID)

        /// 저장 완료
        case saveCompleted

        /// 저장 실패
        case saveFailed(Error)

        // MARK: Alert Dismiss

        /// 에러 Alert dismiss
        case dismissErrorAlert

        /// 저장 완료 Alert dismiss
        case dismissSaveCompletedAlert
    }

    // MARK: - Reducer

    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .toggleSelection(index):
            if state.selectedIndex.contains(index) {
                state.selectedIndex.remove(index)
                state.typeSelections.removeValue(forKey: index)
            } else {
                state.selectedIndex.insert(index)

                if state.typeSelections[index] == nil {
                    state.typeSelections[index] = .allCases.first
                }
            }
            return .none

        case let .selectType(index, type):
            state.typeSelections[index] = type
            return .none

            // MARK: Duplicate Check

        case let .checkDuplicateLocations(locations, caseID):
            // CoreData에서 기존 Location 조회
            return .task { [repository] in
                do {
                    let existingLocations = try await repository.fetchLocations(caseId: caseID)

                    // 중복 체크 (displayAddress 기준)
                    for location in locations {
                        if existingLocations.contains(where: { $0.address == location.address }) {
                            return .duplicateFound(
                                address: location.address,
                                locations: locations,
                                caseID: caseID
                            )
                        }
                    }

                    // 중복 없음
                    return .noDuplicatesFound(locations: locations, caseID: caseID)

                } catch {
                    return .saveFailed(error)
                }
            }

        case let .duplicateFound(address, locations, caseID):
            // 중복 발견 → Alert 표시
            state.showDuplicateAlert = true
            state.duplicateAddress = address
            state.pendingLocations = locations
            state.currentCaseID = caseID
            return .none

        case let .noDuplicatesFound(locations, caseID):
            // 중복 없음 → 바로 저장
            return .send(.executeSave(locations: locations, caseID: caseID))

        case .confirmOverwrite:
            // 덮어쓰기 확인 → 저장 진행
            state.showDuplicateAlert = false

            guard let locations = state.pendingLocations as [Location]?,
                  let caseID = state.currentCaseID
            else {
                return .none
            }

            return .send(.executeSave(locations: locations, caseID: caseID))

        case .cancelOverwrite:
            // 덮어쓰기 취소
            state.showDuplicateAlert = false
            state.pendingLocations = []
            return .none

            // MARK: Save

        case let .saveButtonTapped(caseID):
            guard state.canAddPin else {
                return .none
            }

            state.isSaving = true
            state.errorMessage = nil

            // ScanResult → Location 변환 (좌표는 이미 검증됨)
            let locations: [Location] = state.selectedIndex.map { index in
                let result = state.scanResults[index]
                let type = state.typeSelections[index]!

                return Location(
                    id: UUID(),
                    address: result.displayAddress, // 신주소 우선, 없으면 구주소
                    title: nil,
                    note: nil,
                    pointLatitude: result.latitude,
                    pointLongitude: result.longitude,
                    boxMinLatitude: nil,
                    boxMinLongitude: nil,
                    boxMaxLatitude: nil,
                    boxMaxLongitude: nil,
                    locationType: type.rawValue,
                    colorType: 0,
                    receivedAt: Date()
                )
            }

            // 중복 체크
            return .send(.checkDuplicateLocations(locations: locations, caseID: caseID))

        case let .executeSave(locations, caseID):
            // 실제 저장 실행 (중복 체크 완료 후)
            return .task { [repository] in
                do {
                    let existingLocations = try await repository.fetchLocations(caseId: caseID)
                    for location in locations {
                        if let existing = existingLocations.first(where: { $0.address == location.address }) {
                            try await repository.deleteLocation(id: existing.id)
                        }
                    }

                    // 새 Location 저장
                    try await repository.createLocations(data: locations, caseId: caseID)
                    return .saveCompleted
                } catch {
                    return .saveFailed(error)
                }
            }

        case .saveCompleted:
            state.isSaving = false
            state.isSaveCompleted = true
            state.pendingLocations = []
            state.currentCaseID = nil
            return .none

        case let .saveFailed(error):
            state.isSaving = false
            state.errorMessage = error.localizedDescription
            state.pendingLocations = []
            state.currentCaseID = nil
            return .none

        case .dismissErrorAlert:
            state.errorMessage = nil
            return .none

        case .dismissSaveCompletedAlert:
            state.isSaveCompleted = false
            return .none
        }
    }
}
