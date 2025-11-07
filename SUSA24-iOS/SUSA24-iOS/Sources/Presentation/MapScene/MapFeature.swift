//
//  MapFeature.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import NMapsMap
import SwiftUI

// MARK: - Reducer

/// 지도 화면의 상태와 액션을 관리하는 Reducer입니다.
struct MapFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - State
    
    /// 지도 화면의 상태를 나타냅니다.
    struct State: DWState {
        /// 표시할 위치 데이터 배열입니다.
        var locations: [Location] = []
        /// 현재 선택된 케이스의 UUID입니다.
        var caseId: UUID?
        
        /// 기지국 범위 필터의 선택 상태입니다.
        var isBaseStationRangeSelected: Bool = false
        /// 누적 빈도 필터의 선택 상태입니다.
        var isVisitFrequencySelected: Bool = false
        /// 최근 기지국 필터의 선택 상태입니다.
        var isRecentBaseStationSelected: Bool = false
        
        /// 지도 레이어 시트의 표시 상태입니다.
        var isMapLayerSheetPresented: Bool = false
        
        // MARK: - 위치정보 시트 관련 상태
        
        /// 위치정보 시트의 표시 상태입니다.
        var isPlaceInfoSheetPresented: Bool = false
        /// 위치정보 시트의 로딩 중 여부입니다.
        var isPlaceInfoLoading: Bool = false
        /// 선택된 위치정보 데이터입니다.
        var selectedPlaceInfo: PlaceInfo?
    }
    
    // MARK: - Action
    
    /// 지도 화면에서 발생할 수 있는 액션입니다.
    enum Action: DWAction {
        /// 화면이 나타날 때 발생하는 액션입니다.
        case onAppear
        /// 위치 데이터를 로드하는 액션입니다.
        /// - Parameter locations: 로드할 위치 데이터 배열
        case loadLocations([Location])
        /// 필터를 선택/해제하는 액션입니다.
        /// - Parameter filter: 선택할 필터 타입
        case selectFilter(MapFilterType)
        /// 지도 레이어 시트를 토글하는 액션입니다.
        case toggleMapLayerSheet
        
        // MARK: - 위치정보 시트 관련 액션
        
        /// 맵을 터치했을 때 발생하는 액션입니다.
        /// 위치정보 시트를 표시하고 Kakao API를 호출하여 위치정보를 조회합니다.
        /// - Parameter latlng: 터치한 좌표
        case mapTapped(NMGLatLng)
        /// 위치정보를 표시하는 액션입니다.
        /// API 호출 완료 후 위치정보 데이터를 시트에 표시합니다.
        /// - Parameter placeInfo: 표시할 위치정보 데이터
        case showPlaceInfo(PlaceInfo)
        /// 위치정보 시트를 닫는 액션입니다.
        case hidePlaceInfo
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            guard let caseId = state.caseId else { return .none }
            return .task { [repository] in
                do {
                    // NOTE: 테스트용 목데이터 저장 로직
                    // 케이스 선택 시 해당 케이스의 빈 문자열("") suspect에 Location 목데이터 저장
                    // 실제 데이터가 없을 경우를 대비한 테스트 데이터
                    // 프로토콜에는 포함되지 않으므로 타입 캐스팅 사용
                    if let locationRepository = repository as? LocationRepository {
                        try await locationRepository.loadMockDataIfNeeded(caseId: caseId)
                    }
                    
                    let locations = try await repository.fetchLocations(caseId: caseId)
                    return .loadLocations(locations)
                } catch {
                    return .none
                }
            }
            
        case let .loadLocations(locations):
            state.locations = locations
            return .none
            
        case let .selectFilter(filter):
            switch filter {
            case .cellStationRange:
                state.isBaseStationRangeSelected.toggle()
            case .visitFrequency:
                state.isVisitFrequencySelected.toggle()
            case .recentBaseStation:
                state.isRecentBaseStationSelected.toggle()
            }
            return .none
            
        case .toggleMapLayerSheet:
            state.isMapLayerSheetPresented.toggle()
            return .none
            
        // MARK: - 위치정보 시트 관련 액션 처리
            
        case let .mapTapped(latlng):
            // 위치정보 시트 표시 및 로딩 상태 설정
            state.isPlaceInfoLoading = true
            state.isPlaceInfoSheetPresented = true
            state.selectedPlaceInfo = PlaceInfo(
                title: "",
                jibunAddress: "",
                roadAddress: "",
                phoneNumber: ""
            )
            let requestDTO = latlng.toKakaoRequestDTO()
            return .task {
                do {
                    let placeInfo = try await fetchPlaceInfo(from: requestDTO)
                    return .showPlaceInfo(placeInfo)
                } catch {
                    // API 호출 실패 시 빈 데이터로 시트 표시
                    return .showPlaceInfo(PlaceInfo(
                        title: "",
                        jibunAddress: "",
                        roadAddress: "",
                        phoneNumber: ""
                    ))
                }
            }
            
        case let .showPlaceInfo(placeInfo):
            // 위치정보 데이터를 상태에 저장하고 로딩 완료 처리
            state.selectedPlaceInfo = placeInfo
            state.isPlaceInfoLoading = false
            state.isPlaceInfoSheetPresented = true
            return .none
            
        case .hidePlaceInfo:
            // 위치정보 시트 닫기 및 상태 초기화
            state.isPlaceInfoSheetPresented = false
            state.isPlaceInfoLoading = false
            state.selectedPlaceInfo = nil
            return .none
        }
    }
    
    // MARK: - 위치정보 시트 관련 함수
    
    /// 좌표를 기반으로 위치정보를 조회합니다.
    /// - Parameter requestDTO: 조회할 좌표의 요청 DTO
    /// - Returns: 조회된 위치정보 데이터
    /// - Throws: API 호출 실패 시 에러를 던집니다.
    private func fetchPlaceInfo(from requestDTO: KakaoCoordToLocationRequestDTO) async throws -> PlaceInfo {
        // 1단계: 좌표로 주소 조회 (Kakao 좌표→주소 변환 API)
        let coordResponse = try await KakaoSearchAPIManager.shared.fetchLocationFromCoord(requestDTO)
        guard let document = coordResponse.documents.first else {
            return PlaceInfo(
                title: "",
                jibunAddress: "",
                roadAddress: "",
                phoneNumber: ""
            )
        }
        let landAddress = document.address?.addressName ?? ""
        let roadAddress = document.roadAddress?.addressName ?? ""
        
        // 2단계: buildingName이 있으면 키워드 검색 (Kakao 키워드→장소 검색 API)
        // buildingName이 있는 경우, 장소명과 전화번호를 추가로 조회
        if let buildingName = document.roadAddress?.buildingName, !buildingName.isEmpty {
            let keywordRequestDTO = KakaoKeywordToPlaceRequestDTO(
                query: roadAddress,
                x: document.roadAddress?.x,
                y: document.roadAddress?.y,
                radius: 100,
                page: 1,
                size: 1
            )
            
            let keywordResponse = try await KakaoSearchAPIManager.shared.fetchPlaceFromKeyword(keywordRequestDTO)
            
            if let placeDocument = keywordResponse.documents.first {
                // 키워드 검색 성공: 장소명과 전화번호 포함하여 표시
                let title = placeDocument.placeName ?? buildingName
                let phoneNumber = placeDocument.phone ?? ""
                return PlaceInfo(
                    title: title,
                    jibunAddress: landAddress,
                    roadAddress: roadAddress,
                    phoneNumber: phoneNumber
                )
            }
        }
        
        // buildingName이 없거나 키워드 검색 실패 시: 주소 정보만 표시
        // title은 도로명 주소가 있으면 도로명 주소, 없으면 지번 주소
        let title = roadAddress.isEmpty ? landAddress : roadAddress
        return PlaceInfo(
            title: title,
            jibunAddress: landAddress,
            roadAddress: roadAddress,
            phoneNumber: ""
        )
    }
}

// MARK: - Map Filter Type

/// 지도 화면에서 사용하는 필터 타입입니다.
enum MapFilterType: String, CaseIterable {
    case cellStationRange = "기지국 범위"
    case visitFrequency = "누적 빈도"
    case recentBaseStation = "최근 기지국"
    
    var iconName: String {
        switch self {
        case .cellStationRange:
            "icn_cell_range_filter"
        case .visitFrequency:
            "icn_visit_frequency_filter"
        case .recentBaseStation:
            "icn_cell_station_filter"
        }
    }
}
