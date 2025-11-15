//
//  MapDispatcher.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/8/25.
//

import Observation

/// 지도 관련 명령을 한 곳에서 publish/consume 하도록 연결해 주는 **단일 진입점(Map Dispatcher)** 입니다.
///
/// ### 역할
/// - `MapView`가 `onChange(of: dispatcher.request)`로 변화를 감시하며, 들어온 명령에 맞춰 네이버 지도 SDK를 제어합니다.
/// - 검색 화면(`SearchFeature`)처럼 지도 이동·표시가 필요한 다른 씬은 `request` 프로퍼티에 값을 할당해 명령을 등록합니다.
/// - 명령을 소비한 쪽(`MapFeature`)은 반드시 `request = nil`로 되돌려 중복 실행을 방지합니다.
///
/// ### 동작 원리
/// 1. 여러 뷰/리듀서가 `request`에 명령을 기록합니다. (`MapDispatcher`는 가장 최근 요청만을 보관합니다.)
/// 2. `MapView`는 `@Observable`의 변경 사항을 감지해 명령을 `MapFeature` 액션으로 전달합니다.
/// 3. Reducer가 상태를 업데이트하고, 명령 처리 후 `request`를 `nil`로 초기화합니다.
///
/// ### 사용 예시
/// ```swift
/// // 1) 검색 결과를 선택하면 명령을 발행
/// dispatcher.request = .moveToSearchResult(
///     coordinate: MapCoordinate(latitude: 37.5, longitude: 127.0),
///     placeInfo: placeInfo
/// )
///
/// // 2) MapView에서 명령을 감지해 Reducer에 위임
/// .onChange(of: dispatcher.request) { _, request in
///     guard let request else { return }
///     switch request {
///     case let .moveToSearchResult(coordinate, placeInfo):
///         store.send(.moveToSearchResult(coordinate, placeInfo))
///     }
/// }
/// ```
@Observable
final class MapDispatcher {
    /// 다른 뷰로부터 입력된 요청입니다. MapView 감지하여 onChange로 Action을 실행시킵니다.
    private(set) var request: RequestType?
    
    /// 외부 모듈에서 지도 명령을 발행합니다.
    func send(_ request: RequestType) {
        self.request = request
    }
    
    /// 명령 완료를 표시합니다.
    func consume() {
        request = nil
    }
    
    /// MapDispatcher가 전달할 수 있는 지도 명령 요청의 목록입니다.
    enum RequestType: Equatable {
        /// 검색 결과를 기반으로 지도 카메라를 이동시키고, 동시에 바텀시트에 보여줄 정보를 제공합니다.
        case moveToSearchResult(coordinate: MapCoordinate, placeInfo: PlaceInfo)
        /// Timeline에서 선택한 Location으로 지도 카메라를 이동시킵니다.
        case moveToLocation(coordinate: MapCoordinate)
    }
}
