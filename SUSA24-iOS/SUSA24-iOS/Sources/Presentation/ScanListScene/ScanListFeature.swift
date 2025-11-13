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
struct ScanListFeature: DWReducer {
    // MARK: - Dependencies

    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - State

    struct State: DWState {
        /// 분석 결과 목록
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

        // MARK: Save

        /// "편 추가하기" 버튼 탭
        case saveButtonTapped(caseID: UUID)

        /// 저장 완료
        case saveCompleted

        /// 저장 실패
        case saveFailed(Error)
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

        case let .saveButtonTapped(caseID):
            guard state.canAddPin else {
                return .none
            }

            state.isSaving = true
            state.errorMessage = nil

            // ScanResult → Location 변환
            let locations: [Location] = state.selectedIndex.map { index in
                let result = state.scanResults[index]
                let type = state.typeSelections[index]!

                return Location(
                    id: UUID(),
                    address: result.address,
                    title: nil,
                    note: nil,
                    pointLatitude: 0.0, // TODO: Geocoding
                    pointLongitude: 0.0,
                    boxMinLatitude: nil,
                    boxMinLongitude: nil,
                    boxMaxLatitude: nil,
                    boxMaxLongitude: nil,
                    locationType: type.rawValue,
                    colorType: 0, // PinCategoryType → Int16
                    receivedAt: Date()
                )
            }

            return .task { [repository] in
                do {
                    try await repository.createLocations(data: locations, caseId: caseID)
                    return .saveCompleted
                } catch {
                    return .saveFailed(error)
                }
            }

        case .saveCompleted:
            state.isSaving = false
            state.isSaveCompleted = true
            return .none

        case let .saveFailed(error):
            state.isSaving = false
            state.errorMessage = error.localizedDescription
            return .none
        }
    }
}
