//
//  MapFeature.swift
//  SUSA24-iOS
//
//  Updated by Moo on 11/13/25.
//

import Foundation
import NMapsMap

// MARK: - Reducer

/// 지도 씬의 비즈니스 로직 및 명령 전달을 담당하는 Reducer입니다.
/// - 두 가지 의존성을 받습니다.
///   1. `repository`: CoreData 또는 API로부터 위치 데이터를 읽기 위한 저장소
///   2. `dispatcher`: 다른 모듈(Search 등)에서 발생한 지도 명령을 전달받기 위한 버스 객체
struct MapFeature: DWReducer {
    private let repository: LocationRepositoryProtocol
    private let searchService: SearchAPIService
    private let cctvService: CCTVAPIService
    private let dispatcher: MapDispatcher
    
    init(
        repository: LocationRepositoryProtocol,
        searchService: SearchAPIService,
        cctvService: CCTVAPIService,
        dispatcher: MapDispatcher
    ) {
        self.repository = repository
        self.searchService = searchService
        self.cctvService = cctvService
        self.dispatcher = dispatcher
    }
    
    // MARK: - State
    
    /// 지도 화면의 상태를 나타냅니다.
    struct State: DWState {
        // MARK: 데이터 소스
        
        /// 표시할 위치 데이터 배열입니다.
        var locations: [Location] = []
        /// 표시할 기지국 데이터 배열입니다.
        var cellStations: [CellMarker] = []
        /// 표시할 CCTV 데이터 배열입니다.
        var cctvMarkers: [CCTVMarker] = []
        /// 화면에 표시 중인 CCTV 캐시(ID -> CCTVMarker)
        var cctvCache: [String: CCTVMarker] = [:]
        /// CCTV 캐시의 순서를 유지하기 위한 ID 배열 (FIFO)
        var cctvCacheOrder: [String] = []
        /// 현재 캐시가 포괄하는 지도 범위
        var cctvCachedBounds: MapBounds?
        /// 현재 진행 중인 fetch가 요청한 범위
        var cctvPendingFetchBounds: MapBounds?
        /// 마지막으로 확인된 지도 범위
        var lastCameraBounds: MapBounds?
        /// 마지막으로 확인된 줌 레벨
        var lastCameraZoom: Double = 0
        /// 현재 선택된 케이스의 UUID입니다. `onAppear` 시 CoreData로부터 위치 데이터를 로드하는 데 사용됩니다.
        var caseId: UUID?
        
        // MARK: 카메라 명령 상태
        
        /// 명령 디스패처로부터 전달된 지도 이동 명령을 반영할 목표 좌표입니다.
        /// `MapView`가 해당 좌표를 소비하면 `.clearCameraTarget` 액션으로 다시 nil로 초기화합니다.
        var cameraTargetCoordinate: MapCoordinate?
        /// 현위치를 포커싱해야 하는지 여부입니다.
        var shouldFocusMyLocation: Bool = false
        /// 초기 진입 시 카메라를 한 번만 설정했는지 여부입니다.
        var didSetInitialCamera: Bool = false
        
        // MARK: 지도 레이어/필터 UI 상태
        
        /// 기지국 범위 필터의 선택 상태입니다.
        var isBaseStationRangeSelected: Bool = false
        /// 누적 빈도 필터의 선택 상태입니다.
        var isVisitFrequencySelected: Bool = false
        /// 최근 기지국 필터의 선택 상태입니다. 최근 기지국 필터 토글 시 사용됩니다.
        var isRecentBaseStationSelected: Bool = false
        
        /// 지도 레이어 시트의 표시 상태입니다. `MapLayerContainer` 버튼 토글과 연결됩니다.
        var isMapLayerSheetPresented: Bool = false
        /// 지도 레이어의 커버리지 반경입니다.
        var mapLayerCoverageRange: CoverageRangeType = .half
        /// CCTV 레이어 표시 여부입니다.
        var isCCTVLayerEnabled: Bool = false
        /// 기지국 레이어 표시 여부입니다.
        var isBaseStationLayerEnabled: Bool = false
        /// CCTV 데이터 로딩 상태입니다.
        var cctvFetchStatus: CCTVFetchStatus = .idle
        
        // MARK: - 위치정보 시트 관련 상태
        
        /// 위치정보 시트의 표시 상태입니다.
        var isPlaceInfoSheetPresented: Bool = false
        /// 위치정보 시트의 로딩 중 여부입니다.
        var isPlaceInfoLoading: Bool = false
        /// 선택된 위치정보 데이터입니다.
        var selectedPlaceInfo: PlaceInfo?
        /// 선택된 위치의 기존 핀 정보가 있는가?
        var existingLocation: Location?
        
        // MARK: - Pin Add/Edit

        var isDeleteAlertPresented: Bool = false
        /// 핀 추가/수정 화면 표시 여부
        var isPinWritePresented: Bool = false
        /// 수정 모드 여부 (true: 수정, false: 추가)
        var isEditMode: Bool = false
        
        // MARK: - Memo Edit

        /// 형사 노트 작성/수정 화면 표시 여부
        var isMemoEditPresented: Bool = false
        
        // MARK: - Computed Properties
        
        /// 선택된 위치에 핀이 존재하는지 여부
        var hasExistingPin: Bool {
            existingLocation != nil
        }
    }
    
    // MARK: - Action
    
    /// 지도 화면에서 발생할 수 있는 액션입니다.
    enum Action: DWAction {
        /// 화면이 나타날 때 발생하는 액션입니다.
        case onAppear
        /// 위치 데이터를 로드하는 액션입니다.
        /// - Parameter locations: 로드할 위치 데이터 배열
        case loadLocations([Location])
        /// 기지국 데이터를 로드하는 액션입니다.
        /// - Parameter cellStations: 로드할 기지국 데이터 배열
        case loadCellMarkers([CellMarker])
        /// 필터를 선택/해제하는 액션입니다.
        /// - Parameter filter: 선택할 필터 타입
        case selectFilter(MapFilterType)
        /// 지도 레이어 시트를 토글하는 액션입니다.
        case toggleMapLayerSheet
        /// 지도 레이어 시트 표시 상태를 직접 설정합니다.
        case setMapLayerSheetPresented(Bool)
        /// 지도 레이어 커버리지 반경을 설정합니다.
        case setMapLayerCoverage(CoverageRangeType)
        /// CCTV 레이어 표시 여부를 설정합니다.
        case setCCTVLayerEnabled(Bool)
        /// 기지국 레이어 표시 여부를 설정합니다.
        case setBaseStationLayerEnabled(Bool)
        
        // MARK: - 위치정보 시트 관련 액션
        
        /// 맵을 터치했을 때 발생하는 액션입니다.
        /// 위치정보 시트를 표시하고 Kakao API를 호출하여 위치정보를 조회합니다.
        /// - Parameter latlng: 터치한 좌표
        case mapTapped(NMGLatLng)
        /// 위치정보를 표시하는 액션입니다.
        /// API 호출 완료 후 위치정보 데이터를 시트에 표시합니다.
        /// - Parameter placeInfo: 표시할 위치정보 데이터
        case showPlaceInfo(PlaceInfo)
        /// 위치정보 시트를 닫는 액션입니다. 사용자가 시트를 드래그 내려 닫거나 Close 버튼을 누를 때 호출됩니다.
        case hidePlaceInfo
        
        // MARK: - CCTV 데이터 로드
        
        /// 카메라 이동이 멈췄을 때 현재 지도를 기준으로 CCTV 데이터를 조회합니다.
        /// - Parameters:
        ///   - bounds: 지도 가시 영역의 경계
        ///   - zoomLevel: 현재 줌 레벨
        case cameraIdle(bounds: MapBounds, zoomLevel: Double)
        /// CCTV 데이터를 조회하는 액션입니다.
        /// - Parameter bounds: 조회할 지도 경계
        case fetchCCTV(MapBounds)
        /// CCTV 데이터 조회가 성공했을 때 호출되는 액션입니다.
        /// - Parameter markers: 조회된 CCTV 정보 목록
        case cctvFetchSucceeded([CCTVMarker])
        /// CCTV 데이터 조회가 실패했을 때 호출되는 액션입니다.
        /// - Parameter message: 오류 메시지
        case cctvFetchFailed(String)

        // MARK: 카메라 명령
        
        /// 검색 결과를 선택했을 때 지도 카메라를 해당 좌표로 이동시키고,
        /// 선택된 장소 정보를 시트에 표시하는 액션입니다.
        /// - Parameters:
        ///   - coordinate: 이동할 지도 좌표
        ///   - placeInfo: 바텀시트에 표시할 장소 메타데이터
        case moveToSearchResult(MapCoordinate, PlaceInfo)
        /// Timeline에서 선택한 Location으로 지도 카메라를 이동시킵니다.
        /// - Parameter coordinate: 이동할 지도 좌표
        case moveToLocation(MapCoordinate)
        /// 지도 카메라 이동이 완료되면 호출되는 액션입니다. `cameraTargetCoordinate`를 초기화합니다.
        case clearCameraTarget
        /// 현위치 버튼을 탭했을 때 호출되는 액션입니다.
        case requestFocusMyLocation
        /// 현위치 포커싱 명령을 소비합니다.
        case clearFocusMyLocationFlag
        
        // MARK: - Pin Actions
        
        /// 핀 추가 버튼 탭
        case addPinTapped
        /// 핀 수정 버튼 탭
        case editPinTapped
        
        /// 핀 삭제 버튼 탭
        case deletePinTapped
        
        /// 삭제 Alert
        case showDeleteAlert
        case hideDeleteAlert
        
        case confirmDeletePin
        case deletePinCompleted
        
        /// 핀 저장 (추가/수정)
        case savePin(Location)
        case savePinCompleted(Location)
        /// 핀 추가/수정 화면 닫기
        case closePinWrite
        
        // MARK: - Memo Actions
        
        /// 형사 노트 버튼 탭
        case memoButtonTapped
        /// 형사 노트 저장
        case memoSaved(String?)
        /// 형사 노즈 저장 완료
        case memoSaveCompleted(Location)
        /// 형사 노트 화면 닫기
        case closeMemoEdit
        /// 형사 노트다 닫히면 다시 PinInfo가 열려야한다
        case reopenPlaceInfoAfterMemo
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case .onAppear:
            guard let caseId = state.caseId else { return .none }
            if state.didSetInitialCamera == false {
                focusLatestCellLocation(&state)
                if state.cameraTargetCoordinate == nil {
                    state.cameraTargetCoordinate = MapCoordinate(latitude: 36.019, longitude: 129.343)
                }
                state.didSetInitialCamera = true
            }

            // 병렬로 데이터 로드
            return .merge(
                // 기존 목데이터 가져오는 방식 주석 처리
//                .task { [repository] in
//                    do {
//                        // NOTE: 테스트용 목데이터 저장 로직
//                        // 케이스 선택 시 해당 케이스의 빈 문자열("") suspect에 Location 목데이터 저장
//                        // 실제 데이터가 없을 경우를 대비한 테스트 데이터
//                        // 프로토콜에는 포함되지 않으므로 타입 캐스팅 사용
//                        if let locationRepository = repository as? LocationRepository {
//                            try await locationRepository.loadMockDataIfNeeded(caseId: caseId)
//                        }
//
//                        let locations = try await repository.fetchLocations(caseId: caseId)
//                        return .loadLocations(locations)
//                    } catch {
//                        return .loadLocations([])
//                    }
//                },
                
                // NOTE: API 붙으면 불러오는 로직 수정 필요.
                .task {
                    do {
                        let cellMarkers = try await CellStationLoader.loadFromJSON()
                        return .loadCellMarkers(cellMarkers)
                    } catch {
                        return .loadCellMarkers([])
                    }
                }
            )
            
        case let .loadLocations(locations):
            state.locations = locations
            
            if state.didSetInitialCamera == false {
                focusLatestCellLocation(&state)
                
                if state.cameraTargetCoordinate == nil {
                    state.cameraTargetCoordinate = MapCoordinate(latitude: 36.019, longitude: 129.343)
                }
                
                state.didSetInitialCamera = true
            }
            return .none
            
        case let .loadCellMarkers(cellStations):
            state.cellStations = cellStations
            return .none
            
        case let .selectFilter(filter):
            switch filter {
            case .cellStationRange:
                state.isBaseStationRangeSelected.toggle()
            case .visitFrequency:
                state.isVisitFrequencySelected.toggle()
            case .recentBaseStation:
                focusRecentBaseStation(&state)
            }
            return .none
            
        case .toggleMapLayerSheet:
            state.isMapLayerSheetPresented.toggle()
            return .none
            
        case let .setMapLayerSheetPresented(isPresented):
            state.isMapLayerSheetPresented = isPresented
            return .none
            
        case let .setMapLayerCoverage(range):
            state.mapLayerCoverageRange = range
            return .none
            
        case let .setCCTVLayerEnabled(isEnabled):
            if let boundsToFetch = prepareCCTVFetchOnToggle(isEnabled: isEnabled, state: &state) {
                return .send(.fetchCCTV(boundsToFetch))
            }
            return .none
            
        case let .setBaseStationLayerEnabled(isEnabled):
            state.isBaseStationLayerEnabled = isEnabled
            return .none
            
        // MARK: - 위치정보 시트 관련 액션 처리
            
        case let .mapTapped(latlng):
            // 위치정보 시트 표시 및 로딩 상태 설정
            // 새 위치 탭하면 기존 핀 정보는 즉시 비워야 함
            state.existingLocation = nil
            state.isEditMode = false
            
            state.isPlaceInfoLoading = true
            state.isPlaceInfoSheetPresented = true
            state.selectedPlaceInfo = nil
            
            let requestDTO = latlng.toKakaoRequestDTO()
            
            return .task {
                do {
                    let placeInfo = try await fetchPlaceInfo(from: requestDTO)
                    return .showPlaceInfo(placeInfo)
                } catch {
                    return .showPlaceInfo(PlaceInfo(
                        title: "",
                        jibunAddress: "",
                        roadAddress: "",
                        phoneNumber: ""
                    ))
                }
            }
            
        case let .showPlaceInfo(placeInfo):
            state.selectedPlaceInfo = placeInfo
            state.isPlaceInfoLoading = false
            state.isPlaceInfoSheetPresented = true
            
            // - roadAddress 또는 jibunAddress 가 동일한 경우 핀 존재
            // - title 은 변동 가능성이 있으므로 비교에서 제외
            let incomingRoad = placeInfo.roadAddress
            let incomingJibun = placeInfo.jibunAddress
            
            state.existingLocation = state.locations.first { loc in
                // 도로명 주소 매칭
                if !incomingRoad.isEmpty, loc.address == incomingRoad {
                    return true
                }
                // 지번 주소 매칭
                if !incomingJibun.isEmpty, loc.address == incomingJibun {
                    return true
                }
                return false
            }
            
            // 추후 좌표로 매칭
            /*
             if let lat = placeInfo.latitude,
             let lng = placeInfo.longitude {
             state.existingLocation = state.locations.first { loc in
             loc.pointLatitude == lat && loc.pointLongitude == lng
             }
             } else {
             state.existingLocation = nil
             }
             */
            
            return .none
            
        case .hidePlaceInfo:
            // 위치정보 시트 닫기 및 상태 초기화
            state.isPlaceInfoSheetPresented = false
            state.isPlaceInfoLoading = false
            state.selectedPlaceInfo = nil
            return .none
            
        case let .cameraIdle(bounds, zoomLevel):
            state.lastCameraBounds = bounds
            state.lastCameraZoom = zoomLevel
            
            if let boundsToFetch = prepareCCTVFetch(bounds: bounds, zoomLevel: zoomLevel, state: &state) {
                return .send(.fetchCCTV(boundsToFetch))
            }
            return .none
            
        case let .fetchCCTV(bounds):
            state.cctvFetchStatus = .fetching
            state.cctvPendingFetchBounds = bounds
            return .task { [cctvService] in
                let requestDTO = await VWorldBoxRequestDTO(
                    minLng: bounds.minLongitude,
                    minLat: bounds.minLatitude,
                    maxLng: bounds.maxLongitude,
                    maxLat: bounds.maxLatitude,
                    size: NMConstants.defaultCCTVFetchSize,
                    page: 1
                )
                    
                do {
                    let response = try await cctvService.fetchCCTVByBox(requestDTO)
                    let markers = await MainActor.run {
                        response.features.compactMap { CCTVMarker(feature: $0) }
                    }
                    return .cctvFetchSucceeded(markers)
                } catch {
                    return .cctvFetchFailed(error.localizedDescription)
                }
            }
            
        case let .cctvFetchSucceeded(markers):
            handleCCTVFetchSucceeded(markers, state: &state)
            return .none
            
        case let .cctvFetchFailed(message):
            handleCCTVFetchFailed(message, state: &state)
            return .none
            
        case let .moveToSearchResult(coordinate, placeInfo):
            // 검색 결과 선택에 따라 지도 카메라를 이동하고, 상세 정보를 표시합니다.
            state.cameraTargetCoordinate = coordinate
            state.selectedPlaceInfo = placeInfo
            state.isPlaceInfoLoading = false
            state.isPlaceInfoSheetPresented = true
            // 명령을 수행했으므로 버스에 보관된 값을 초기화합니다.
            dispatcher.consume()
            return .none

        case let .moveToLocation(coordinate):
            // Timeline에서 선택한 Location으로 지도 카메라를 이동합니다.
            state.cameraTargetCoordinate = coordinate
            // 명령을 수행했으므로 버스에 보관된 값을 초기화합니다.
            dispatcher.consume()
            return .none

        case .clearCameraTarget:
            // 지도 카메라 이동이 완료되었음을 반영합니다.
            state.cameraTargetCoordinate = nil
            return .none
            
        case .requestFocusMyLocation:
            state.shouldFocusMyLocation = true
            return .none
            
        case .clearFocusMyLocationFlag:
            state.shouldFocusMyLocation = false
            return .none
            
            // MARK: - Pin Actions
            
        case .addPinTapped:
            guard let placeInfo = state.selectedPlaceInfo,
                  state.caseId != nil
            else {
                print("❌ Cannot add pin: Missing placeInfo or caseId")
                return .none
            }
            
            state.isEditMode = false
            state.existingLocation = nil
            state.isPinWritePresented = true
            return .none
            
        case .editPinTapped:
            state.isEditMode = true
            state.isPinWritePresented = true
            return .none
            
        // TODO: DWAlert 연동
        case .deletePinTapped:
            return .send(.confirmDeletePin)
            
        case .showDeleteAlert:
            state.isDeleteAlertPresented = true
            return .none

        case .hideDeleteAlert:
            state.isDeleteAlertPresented = false
            return .none

        case .confirmDeletePin:
            guard let locationId = state.existingLocation?.id else { return .none }

            return .task { [repository] in
                do {
                    try await repository.deleteLocation(id: locationId)
                    return .deletePinCompleted
                } catch {
                    return .none
                }
            }

        case .deletePinCompleted:
            guard let deleteId = state.existingLocation?.id else { return .none }

            state.locations.removeAll { $0.id == deleteId }
            state.existingLocation = nil
            state.isPlaceInfoSheetPresented = false
            state.selectedPlaceInfo = nil

            return .none
            
        case let .savePin(location):
            return .task { [repository, caseId = state.caseId] in
                do {
                    if let _ = try await repository.checkLocationExists(address: location.address, caseId: caseId!) {
                        try await repository.updateLocation(location)
                    } else {
                        try await repository.createLocations(data: [location], caseId: caseId!)
                    }
                    return .savePinCompleted(location)
                } catch {
                    print("❌ savePin failed: \(error)")
                    return .none
                }
            }
            
        case let .savePinCompleted(location):
            state.existingLocation = location

            if let index = state.locations.firstIndex(where: { $0.id == location.id }) {
                state.locations[index] = location
            } else {
                state.locations.append(location)
            }

            state.isPinWritePresented = false
            return .none
            
        case .closePinWrite:
            state.isPinWritePresented = false
            return .none
            
            // MARK: - Memo Actions
            
        case .memoButtonTapped:
            state.isPlaceInfoSheetPresented = false
            state.isMemoEditPresented = true
            return .none
            
        case let .memoSaved(note):
            state.isMemoEditPresented = false
            
            guard let existingLocation = state.existingLocation else { return .none }
            
            let updatedLocation = Location(
                id: existingLocation.id,
                address: existingLocation.address,
                title: existingLocation.title,
                note: note,
                pointLatitude: existingLocation.pointLatitude,
                pointLongitude: existingLocation.pointLongitude,
                boxMinLatitude: existingLocation.boxMinLatitude,
                boxMinLongitude: existingLocation.boxMinLongitude,
                boxMaxLatitude: existingLocation.boxMaxLatitude,
                boxMaxLongitude: existingLocation.boxMaxLongitude,
                locationType: existingLocation.locationType,
                colorType: existingLocation.colorType,
                receivedAt: existingLocation.receivedAt
            )
            
            return .task { [repository] in
                do {
                    try await repository.updateLocation(updatedLocation)
                    return .memoSaveCompleted(updatedLocation)
                } catch {
                    return .none
                }
            }
            
        case let .memoSaveCompleted(updatedLocation):
            state.existingLocation = updatedLocation
            if let index = state.locations.firstIndex(where: { $0.id == updatedLocation.id }) {
                state.locations[index] = updatedLocation
            }
            
            if let info = state.selectedPlaceInfo {
                return .send(.showPlaceInfo(info))
            }
            
            return .none
            
        case .closeMemoEdit:
            state.isMemoEditPresented = false
            
            return .send(.reopenPlaceInfoAfterMemo)
            
        case .reopenPlaceInfoAfterMemo:
            guard let info = state.selectedPlaceInfo else { return .none }
            return .task {
                try? await Task.sleep(nanoseconds: 10_000_000)
                return .showPlaceInfo(info)
            }
        }
    }
}

// MARK: - Private Extensions

private extension MapFeature {
    // MARK: - Case Location Helpers

    func focusRecentBaseStation(_ state: inout State) {
        let wasSelected = state.isRecentBaseStationSelected
        state.isRecentBaseStationSelected = false
        // TODO: 버튼으로 전환하여 토글 상태를 유지하지 않도록 설계 변경 필요
        if !wasSelected {
            focusLatestCellLocation(&state)
        }
    }

    func focusLatestCellLocation(_ state: inout State) {
        guard let latestCell = state.locations
            .filter({ LocationType($0.locationType) == .cell })
            .max(by: { lhs, rhs in
                let lhsDate = lhs.receivedAt ?? .distantPast
                let rhsDate = rhs.receivedAt ?? .distantPast
                return lhsDate < rhsDate
            }),
            latestCell.pointLatitude != 0,
            latestCell.pointLongitude != 0 else { return }

        state.cameraTargetCoordinate = MapCoordinate(
            latitude: latestCell.pointLatitude,
            longitude: latestCell.pointLongitude
        )
    }

    // MARK: - Kakao Place Helpers
    
    /// 좌표를 기반으로 카카오 API에서 위치 정보를 조회합니다.
    func fetchPlaceInfo(from requestDTO: KakaoCoordToLocationRequestDTO) async throws -> PlaceInfo {
        // 좌표로 주소 조회 (Kakao 좌표→주소 변환 API)
        let coordResponse = try await searchService.fetchLocationFromCoord(requestDTO)
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
        
        // buildingName이 있으면 키워드 검색 (Kakao 키워드→장소 검색 API)
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
            
            let keywordResponse = try await searchService.fetchPlaceFromKeyword(keywordRequestDTO)
            
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
    
    // MARK: - CCTV Fetch Decision
    
    /// CCTV 레이어 토글 시 fetch가 필요하면 bounds를 반환합니다.
    func prepareCCTVFetchOnToggle(isEnabled: Bool, state: inout State) -> MapBounds? {
        state.isCCTVLayerEnabled = isEnabled
        guard isEnabled, let bounds = state.lastCameraBounds else { return nil }
        return prepareCCTVFetch(bounds: bounds, zoomLevel: state.lastCameraZoom, state: &state)
    }
    
    /// CCTV fetch가 필요한지 판단하고 fetch할 bounds를 반환합니다.
    func prepareCCTVFetch(bounds: MapBounds, zoomLevel: Double, state: inout State) -> MapBounds? {
        guard state.isCCTVLayerEnabled else { return nil }
        guard zoomLevel >= NMConstants.minZoomForCCTV else { return nil }
        
        if let cachedBounds = state.cctvCachedBounds,
           cachedBounds.contains(bounds),
           !state.cctvCache.isEmpty { return nil }
        
        if case .fetching = state.cctvFetchStatus { return nil }
        
        state.cctvPendingFetchBounds = bounds
        return bounds
    }
    
    // MARK: - CCTV Fetch Result Handling
    
    /// CCTV fetch 성공 시 캐시와 상태를 갱신합니다.
    func handleCCTVFetchSucceeded(_ markers: [CCTVMarker], state: inout State) {
        state.cctvFetchStatus = .idle
        defer { state.cctvPendingFetchBounds = nil }
        
        if let fetchBounds = state.cctvPendingFetchBounds {
            if let cachedBounds = state.cctvCachedBounds, cachedBounds.intersects(fetchBounds) {
                state.cctvCachedBounds = cachedBounds.union(fetchBounds)
            } else {
                resetCCTVCache(&state)
                state.cctvCachedBounds = fetchBounds
            }
        } else {
            resetCCTVCache(&state)
            state.cctvCachedBounds = nil
        }
        
        mergeCCTVMarkers(markers, into: &state)
    }
    
    /// CCTV fetch 실패 시 상태를 갱신합니다.
    func handleCCTVFetchFailed(_ message: String, state: inout State) {
        state.cctvFetchStatus = .failed(message)
        state.cctvPendingFetchBounds = nil
    }
    
    // MARK: - CCTV Cache Management
    
    /// CCTV 캐시를 초기화합니다.
    func resetCCTVCache(_ state: inout State) {
        state.cctvCache.removeAll()
        state.cctvCacheOrder.removeAll()
    }
    
    /// 새로 로드된 CCTV 마커를 캐시에 병합합니다.
    func mergeCCTVMarkers(_ markers: [CCTVMarker], into state: inout State) {
        guard !markers.isEmpty else {
            state.cctvMarkers = state.cctvCacheOrder.compactMap { state.cctvCache[$0] }
            return
        }
        
        var uniqueIds: [String] = []
        var seen = Set<String>()
        for marker in markers where seen.insert(marker.id).inserted {
            uniqueIds.append(marker.id)
        }
        
        if !uniqueIds.isEmpty {
            let incomingSet = Set(uniqueIds)
            state.cctvCacheOrder.removeAll { incomingSet.contains($0) }
            state.cctvCacheOrder.append(contentsOf: uniqueIds)
        }
        
        for marker in markers {
            state.cctvCache[marker.id] = marker
        }
        
        trimCCTVCacheIfNeeded(&state)
        state.cctvMarkers = state.cctvCacheOrder.compactMap { state.cctvCache[$0] }
    }
    
    /// CCTV 캐시가 상한을 넘으면 오래된 항목을 제거합니다.
    func trimCCTVCacheIfNeeded(_ state: inout State) {
        let overflow = state.cctvCacheOrder.count - NMConstants.maxCachedCCTVCount
        guard overflow > 0 else { return }
        
        let removedIds = state.cctvCacheOrder.prefix(overflow)
        state.cctvCacheOrder.removeFirst(overflow)
        removedIds.forEach { state.cctvCache.removeValue(forKey: $0) }
    }
}
