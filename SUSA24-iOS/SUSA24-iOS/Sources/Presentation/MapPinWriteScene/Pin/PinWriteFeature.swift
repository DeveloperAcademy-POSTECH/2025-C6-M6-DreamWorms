//
//  PinWriteFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/21/25.
//

import Foundation

// MARK: - Reducer

/// 핀 추가/수정 화면의 비즈니스 로직
struct PinWriteFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    private let onSaveCompleted: (Location) -> Void
    
    init(
        repository: LocationRepositoryProtocol,
        onSaveCompleted: @escaping (Location) -> Void
    ) {
        self.repository = repository
        self.onSaveCompleted = onSaveCompleted
    }
    
    // MARK: - State
    
    /// 핀 추가/수정 화면의 상태
    struct State: DWState {
        // MARK: 기본 정보
        
        /// 현재 케이스 ID
        let caseId: UUID
        /// 장소 정보 (주소 등)
        let placeInfo: PlaceInfo
        /// 지도 좌표
        let coordinate: MapCoordinate?
        /// 기존 Location (수정 모드일 때)
        let existingLocation: Location?
        /// 수정 모드 여부
        var isEditMode: Bool { existingLocation != nil }
        
        // MARK: 입력 상태
        
        /// 핀 이름
        var pinName: String = ""
        /// 선택된 색상
        var selectedColor: PinColorType = .black
        /// 선택된 카테고리
        var selectedCategory: PinCategoryType = .home
        /// 핀 이름 입력 필드 포커스 여부
        var isPinNameFocused: Bool = true
        
        // MARK: 유효성 검사
        
        /// 핀 이름 유효성: 한글자 이상, 20자 이하, 이모지 완전 차단
        var isValidPinName: Bool {
            let trimmedName = pinName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty, trimmedName.count <= 20 else { return false }
            
            // 이모지 포함 여부 확인
            return !trimmedName.containsEmoji
        }
    }
    
    // MARK: - Action
    
    enum Action: DWAction {
        /// 화면 진입 시 호출 (기존 데이터 로드)
        case onAppear
        
        /// 핀 이름 입력
        case updatePinName(String)
        
        /// 색상 선택
        case selectColor(PinColorType)
        
        /// 카테고리 선택
        case selectCategory(PinCategoryType)
        
        /// 저장 버튼 탭
        case saveTapped
        
        /// 저장 완료 (성공)
        case saveCompleted(Location)
        
        /// 취소 버튼 탭
        case cancelTapped
    }
    
    // MARK: - Reduce
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            // 수정 모드일 때 기존 데이터 로드
            if let location = state.existingLocation {
                state.pinName = location.title ?? ""
                state.selectedColor = PinColorType(rawValue: location.colorType) ?? .black
                state.selectedCategory = PinCategoryType(rawValue: location.locationType) ?? .home
            }
            state.isPinNameFocused = true
            return .none
            
        case let .updatePinName(name):
            state.pinName = name
            return .none
            
        case let .selectColor(color):
            state.selectedColor = color
            return .none
            
        case let .selectCategory(category):
            state.selectedCategory = category
            return .none
            
        case .saveTapped:
            guard state.isValidPinName else { return .none }
            
            // 좌표 결정 로직
            let coordinateSource = state.existingLocation.map {
                MapCoordinate(latitude: $0.pointLatitude, longitude: $0.pointLongitude)
            } ?? state.coordinate
            
            // 좌표가 없는 예외 상황: 저장을 진행할 수 없음
            guard let coordinateSource else { return .none }
            
            let location = Location(
                id: state.existingLocation?.id ?? UUID(),
                address: state.placeInfo.jibunAddress,
                title: state.pinName.trimmingCharacters(in: .whitespacesAndNewlines),
                note: state.existingLocation?.note,
                pointLatitude: coordinateSource.latitude,
                pointLongitude: coordinateSource.longitude,
                boxMinLatitude: nil,
                boxMinLongitude: nil,
                boxMaxLatitude: nil,
                boxMaxLongitude: nil,
                locationType: state.selectedCategory.rawValue,
                colorType: state.selectedColor.rawValue,
                receivedAt: Date()
            )
            
            return .task { [repository, existingLocation = state.existingLocation, caseId = state.caseId] in
                do {
                    // 수정 모드일 때는 업데이트, 추가 모드일 때는 생성
                    if existingLocation != nil {
                        try await repository.updateLocation(location)
                    } else {
                        try await repository.createLocations(data: [location], caseId: caseId)
                    }
                    return .saveCompleted(location)
                } catch {
                    return nil
                }
            }
            
        case let .saveCompleted(location):
            // 상위로 저장 완료 알림
            onSaveCompleted(location)
            return .none
            
        case .cancelTapped:
            // 취소 처리는 상위(MapView)에서 담당
            return .none
        }
    }
}
