//
//  NoteWriteFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/21/25.
//

import Foundation

// MARK: - Reducer

/// 형사 노트 작성/수정 화면의 비즈니스 로직을 담당하는 Reducer입니다.
struct NoteWriteFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    private let onSaveCompleted: (String?) -> Void
    
    init(
        repository: LocationRepositoryProtocol,
        onSaveCompleted: @escaping (String?) -> Void
    ) {
        self.repository = repository
        self.onSaveCompleted = onSaveCompleted
    }
    
    // MARK: - State
    
    /// 형사 노트 작성/수정 화면의 상태를 나타냅니다.
    struct State: DWState {
        // MARK: 기본 정보
        
        /// 기존 노트 내용 (수정 모드일 때)
        let existingNote: String?
        /// 기존 Location 정보
        let existingLocation: Location
        
        // MARK: 입력 상태
        
        /// 노트 텍스트
        var noteText: String = ""
        /// 텍스트 에디터 포커스 여부
        var isTextEditorFocused: Bool = false
        /// 삭제 확인 Alert 표시 여부
        var showDeleteConfirmation: Bool = false
        
        // MARK: 유효성 검사
        
        /// 노트에 내용이 있는지 확인
        var hasNote: Bool {
            !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 화면 진입 시 호출 (기존 데이터 로드)
        case onAppear
        
        /// 포커스 설정 완료
        case focusCompleted
        
        /// 노트 텍스트 업데이트
        case updateNoteText(String)
        
        /// 저장 버튼 탭
        case saveTapped
        
        /// 삭제 버튼 탭
        case deleteTapped
        
        /// 삭제 확인
        case confirmDelete
        
        /// 삭제 Alert 닫기
        case dismissDeleteAlert
        
        /// 저장 완료 (성공)
        case saveCompleted(Location)
        
        /// 취소 버튼 탭
        case cancelTapped
    }
    
    // MARK: - Reduce
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            // 기존 노트 내용 로드
            state.noteText = state.existingNote ?? ""
            
            // 약간의 딜레이 후 포커스 설정
            return DWEffect { downstream in
                try? await Task.sleep(nanoseconds: 450_000_000)
                downstream(.focusCompleted)
            }
            
        case .focusCompleted:
            state.isTextEditorFocused = true
            return .none
            
        case let .updateNoteText(text):
            state.noteText = text
            return .none
            
        case .saveTapped:
            let trimmed = state.noteText.trimmingCharacters(in: .whitespacesAndNewlines)
            let noteToSave = trimmed.isEmpty ? nil : trimmed
            
            let updatedLocation = Location(
                id: state.existingLocation.id,
                address: state.existingLocation.address,
                title: state.existingLocation.title,
                note: noteToSave,
                pointLatitude: state.existingLocation.pointLatitude,
                pointLongitude: state.existingLocation.pointLongitude,
                boxMinLatitude: state.existingLocation.boxMinLatitude,
                boxMinLongitude: state.existingLocation.boxMinLongitude,
                boxMaxLatitude: state.existingLocation.boxMaxLatitude,
                boxMaxLongitude: state.existingLocation.boxMaxLongitude,
                locationType: state.existingLocation.locationType,
                colorType: state.existingLocation.colorType,
                receivedAt: state.existingLocation.receivedAt
            )
            
            return .task { [repository] in
                do {
                    try await repository.updateLocation(updatedLocation)
                    return .saveCompleted(updatedLocation)
                } catch {
                    return nil
                }
            }
            
        case .deleteTapped:
            state.showDeleteConfirmation = true
            return .none
            
        case .confirmDelete:
            state.showDeleteConfirmation = false
            
            // 노트를 nil로 설정하여 삭제
            let updatedLocation = Location(
                id: state.existingLocation.id,
                address: state.existingLocation.address,
                title: state.existingLocation.title,
                note: nil,
                pointLatitude: state.existingLocation.pointLatitude,
                pointLongitude: state.existingLocation.pointLongitude,
                boxMinLatitude: state.existingLocation.boxMinLatitude,
                boxMinLongitude: state.existingLocation.boxMinLongitude,
                boxMaxLatitude: state.existingLocation.boxMaxLatitude,
                boxMaxLongitude: state.existingLocation.boxMaxLongitude,
                locationType: state.existingLocation.locationType,
                colorType: state.existingLocation.colorType,
                receivedAt: state.existingLocation.receivedAt
            )
            
            return .task { [repository] in
                do {
                    try await repository.updateLocation(updatedLocation)
                    return .saveCompleted(updatedLocation)
                } catch {
                    return nil
                }
            }
            
        case .dismissDeleteAlert:
            state.showDeleteConfirmation = false
            return .none
            
        case let .saveCompleted(location):
            // 상위로 저장 완료 알림
            onSaveCompleted(location.note)
            return .none
            
        case .cancelTapped:
            // 취소 처리는 상위(MapView)에서 담당
            return .none
        }
    }
}
