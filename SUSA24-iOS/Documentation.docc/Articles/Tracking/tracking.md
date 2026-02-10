# 추적 기능 (Tracking Feature)
수집된 위치 데이터 중 사용자가 선택한 3개의 위치(핀)를 기반으로 관심 영역(폴리곤)을 정의하고, 해당 영역 내 CCTV 목록을 조회/시각화/공유하는 기능입니다.

> 📅 **작성일**: 2026.01.29  
> 👤 **작성자**: 이민재 (Mini)  
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명

- **Tracking Feature (추적 기능)**

### 기능 정의

Tracking Feature는 ``TrackingSelectionScreen``에서 사용자가 지도 위 3개의 위치 핀 (``Location``) 을 선택하면,  
선택된 좌표로 닫힌 폴리곤 좌표 배열을 구성하고 ``TrackingFeature``가 ``CCTVAPIService``를 호출하여,   영역 내 CCTV 마커 및 목록을 ``TrackingResultScreen``에 제공하는 기능입니다.

### 도입 목적

- CCTV 탐색 범위 축소: 수사관이 관심 구역을 3개의 핀으로 빠르게 정의(폴리곤)하고, 해당 영역 내 CCTV 분포를 즉시 확인하기 위함입니다.
- 공유 가능한 형태로 재가공: 조회 결과를 ShareLink로 텍스트 요약 형태로 제공하여, 메신저/메일 등으로 즉시 공유할 수 있도록 하기 위함입니다.

---

## 2. 기능 적용 범위

### 사용 위치

1. MainTab > TrackingScene: 메인 탭의 추적 탭 (기본 진입)

### 사용자 관점 동작 조건

1. 사용자가 추적 화면에 진입하면 ``TrackingFeature``가 ``LocationRepositoryProtocol``에서 위치 데이터를 로드한다.
2. 사용자가 지도에서 핀을 탭하면 ``TrackingNaverMapView``가 이벤트를 전달하고, ``TrackingSelectionScreen``이 슬롯 상태를 갱신한다.
3. 사용자가 3개의 핀을 모두 선택하면 완료 버튼이 활성화되고, 완료를 누르면 ``TrackingFeature``가 VWorld CCTV 조회를 요청한다.
4. CCTV 조회가 완료되면 ``TrackingResultScreen``에서 CCTV 마커/리스트가 표시되고, 사용자는 공유 버튼으로 결과를 공유할 수 있다.

---

## 3. 화면 흐름도 (Screen Flow)

![추적 탭 화면 흐름도](tracking-screen-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

![추적 탭 시퀀스 다이어그램](tracking-sequence-diagram.svg)

### 4.2 흐름 설명

1. **이벤트 감지 (Event Phase)**
    * NMFMapView에서 발생한 마커 터치 이벤트는 ``TrackingNaverMapView/Coordinator``의 ``MapTouchHandler``에서 1차적으로 감지됩니다.
    * Coordinator는 터치 이벤트를 직접 처리하지 않고, 선택된 Location.id, 표시용 name, 현재 선택 여부(isSelected)를 포함하여 ``TrackingSelectionScreen``의 onLocationTapped(_:_:_:) 콜백으로 즉시 전달합니다.
    * ``TrackingSelectionScreen``은 이 이벤트를 UI Action으로 해석하여,
      - 이미 선택된 핀인 경우 → clearSlot(at:)을 통해 선택 해제
      - 선택되지 않은 핀인 경우 → activeSlotIndex 또는 첫 번째 빈 슬롯에 할당하는 순수 UI 상태 갱신만 수행합니다.
    * 이 단계에서는 네트워크 요청이나 비즈니스 로직은 수행되지 않으며, 오직 View 단의 상태(slots, activeSlotIndex)만 변경됩니다.

2. **비즈니스 로직 처리 (Business Logic Phase)**
    * 사용자가 3개의 슬롯을 모두 채운 뒤 완료 버튼을 탭하면, ``TrackingView``는 현재 선택된 ``Location`` 목록을 계산하여 / ``TrackingFeature/Action/requestCCTV(_:)`` Action을 Store에 전달합니다.
    * ``TrackingFeature``는 Reducer 내부에서:
      1. 선택된 Location 배열을 기반으로 ``TrackingFeature/makeClosedPolygonCoordinates(from:)``를 호출해 닫힌 폴리곤 좌표를 생성하고
      2. ``CCTVAPIService/fetchCCTVByPolygon(_:)``을 통해 VWorld CCTV Polygon API를 비동기로 호출합니다.
    * API 응답은 CCTVMarker 배열로 변환되어 ``TrackingFeature/Action/cctvResponse(_:)`` 액션으로 다시 Reducer에 전달됩니다.
    * 이 과정에서 로딩 상태(``TrackingFeature/State/isCCTVLoading``)와 결과 데이터(``TrackingFeature/State/cctvMarkers``)는 모두 State로 관리되며, View는 Reducer 외부에서 직접 API를 호출하지 않습니다.

3. **렌더링 동기화 (Rendering Phase)** 
    * ``TrackingFeature/State``가 변경되면, 이를 구독 중인 ``TrackingView``가 변화를 감지합니다.
    * isResultMode가 true로 전환되면, 렌더링 흐름에 따라 ``TrackingResultScreen``이 표시됩니다.
    * ``TrackingResultScreen``은 변경된 State를 기반으로 ``TrackingNaverMapView``에 아래와 같은 데이터를 전달합니다:
      - locations
      - selectedLocationIDs
      - cctvMarkers
    * SwiftUI 라이프사이클에 따라 updateUIView가 호출되면, ``TrackingNaverMapView/Coordinator``는
      - 선택된 핀 마커 상태 갱신
      - 선택된 위치 간 Path(2개) 또는 Polygon(3개 이상) Overlay 렌더링
      - CCTV 마커 레이어 업데이트를 수행하여 현재 State와 지도 화면을 동기화합니다.
    * 이때 지도는 명령형 SDK(Naver Map) 를 사용하지만, 어떤 요소를 그릴지는 전적으로 State가 결정하며 View나 Coordinator는 State를 해석해 “어떻게 그릴지”만 책임집니다.

> Tip:
> 
> Tracking Feature에서 새로운 지도 기반 기능을 확장해야 할 경우에도 다음 원칙을 유지하는 것을 권장합니다.
> 1. 지도 이벤트는 View/Coordinator에서 Action으로 변환하고
> 2. 비즈니스 판단(API 호출, 조건 분기)은 반드시 ``TrackingFeature``에서 수행하며
> 3. 지도 렌더링은 State 변경의 결과로만 발생하도록 합니다.
>
> 이 패턴을 유지하면, Selection / Result / Expanded Map 등 화면이 늘어나더라도
> UI–비즈니스–렌더링 간 책임이 명확한 구조를 안정적으로 유지할 수 있습니다.

---

## 5. 상태 다이어그램 (State Diagram)

TrackingFeature.swift와 TrackingView.swift의 상태 변수 정의와, 이에 따른 화면 모드 전환(State Transition) 명세입니다.

### 5.1 상태 변수 정의 (State Variables)
Tracking Feature는 2종류의 상태로 화면을 제어합니다.
1. Store State: TrackingFeature/State (데이터/로딩 상태)

| Variable Name | Description | Available Interactions |
| :--- | :--- | :--- |
| ``TrackingFeature/State/caseId`` | 현재 추적 대상 케이스 ID | • 화면 진입 시 로드 기준 |
| ``TrackingFeature/State/locations`` | 지도에 표시할 위치 핀 목록(중복 제거 적용) | • 지도에서 핀 탭(선택/해제) |
| ``TrackingFeature/State/cctvMarkers`` | VWorld 폴리곤 조회 결과 CCTV 마커 목록 | • 결과 화면 리스트/지도 렌더링 |

2. View Local State: TrackingView / TrackingResultScreen의 @State (화면 모드/인터랙션 상태)

| Variable Name | Description | Available Interactions |
| :--- | :--- | :--- |
| isResultMode | Selection ↔ Result 화면 전환 플래그 | • 완료 버튼 탭 → Result 진입  • 뒤로가기 → Selection 복귀 |
| slots | 사용자가 선택한 3개 핀의 표시 텍스트 | • 핀 선택/해제 반영  • 완료 버튼 활성화 조건 |
| slotLocationIds | 슬롯이 참조하는 Location ID 배열 | • 선택 영역(Overlay) 구성 기준 |
| activeSlotIndex | 사용자가 “다음 탭을 채울 슬롯”으로 지정한 인덱스 | • 빈 슬롯 탭 → 활성화  • 핀 탭 → 해당 슬롯에 할당 |
| isMapExpanded (Result) | 결과 화면에서 지도 확장 모드 | • 확장/축소 버튼 탭 |

> Note:
> - 초기 상태(Initial State): ``TrackingView`` 진입 직후 isResultMode == false, slots == [nil, nil, nil], activeSlotIndex == nil 입니다.
> - CCTV 요청 가능 조건: slots.allSatisfy({ $0 != nil }) == true (3개 선택 완료)일 때만 완료 버튼이 활성화됩니다.
> - Store와 View 분리: 핀 선택 UI(슬롯)는 View Local State가 담당하고, 데이터 로딩/네트워크 결과는 Store State가 담당합니다.

### 5.2 상태 다이어그램 (Visual Diagram)

![추적 탭 상태 다이어그램](tracking-state-diagram.svg)

### 5.3 주요 전이 상세 (Transition Details)
- **Selection 진입 → 위치 로딩**
    - **Action**: ``TrackingFeature/Action/onAppear(_:)``
    - **Effect**: state.caseId 설정, repository fetch → .locationsLoaded
- **위치 로딩 완료 → 핀 선택 가능**
    - **Action**: ``TrackingFeature/Action/locationsLoaded(_:)``
    - **Effect**: state.locations = locations.deduplicatedByCoordinate()
- **핀 선택/해제 (Selection 내부)**
    - **Action**: ``TrackingNaverMapView/Coordinator`` → onLocationTapped(id:name:isSelected)
    - **Effect**:
        - isSelected == true → TrackingSelectionScreen.clearSlot(at:)로 해제 + 당김 처리
        - isSelected == false → activeSlotIndex 또는 첫 빈 슬롯에 할당
- **3개 선택 완료 → CCTV 요청**
    - **Action**: ``TrackingView``의 onDone → ``TrackingFeature/Action/requestCCTV(_:)``
    - **Effect**:
        - makeClosedPolygonCoordinates(from:)로 좌표 구성
        - ``CCTVAPIService/fetchCCTVByPolygon(_:)`` 호출
- **CCTV 응답 수신 → Result 전환**
    - **Action**: ``TrackingFeature/Action/cctvResponse(_:)``
    - **Effect**:
        - 성공: state.cctvMarkers = markers
        - 실패: state.cctvMarkers = []
        - View: isResultMode = true (Result 화면 표시)
- **Result ↔ ExpandedMap**
    - **Action**: ``TrackingResultScreen``의 expand/collapse 버튼 탭
    - **Effect**: isMapExpanded 토글 + matchedGeometryEffect로 확장 애니메이션
- **Result → Selection 복귀**
    - **Action**: ``TrackingResultScreen`` Back 버튼 → ``TrackingView/resetTrackingState()``
    - **Effect**: slots/slotLocationIds/activeSlotIndex 초기화 + isResultMode = false

---

## 6. 의존성 다이어그램 (Dependency Diagram)

![추적 탭 의존성 다이어그램](tracking-dependency-diagram.svg)

## 7. 파일 구조

```
Sources/
├── 📁 Presentation/
│    └── 🗂️ TrackingScene/
│         ├── 🗂️ Models/
│         │    └── CCTVItem.swift                // UI용 CCTV 모델
│         ├── 🗂️ SubViews/
│         │    ├── CCTVSelectionPanel.swift           // 상단 슬롯 패널 UI
│         │    ├── TrackingNaverMapView.swift         // NMFMapView 브릿지 + 마커/오버레이 렌더링
│         │    ├── TrackingResultScreen.swift         // CCTV 결과 화면 + 공유/지도 확장
│         │    └── TrackingSelectionScreen.swift      // 핀 선택 화면
│         ├── TrackingView.swift                 // 엔트리: Selection/Result 전환 + 탭바 제어
│         └── TrackingFeature.swift              // Reducer: 위치 로딩 + CCTV 조회
└── 📁 Util/
     └── 🗂️ Network/
          └── 🗂️ Service/
               └── VWorldCCTVAPIService.swift         // VWorld Polygon API 호출용
```

---

## 8. 예외 상황 및 대응 기준

### 예외 상황 1: 위치 데이터 로딩 실패
- **증상**: 지도에 위치 핀이 표시되지 않음
- **원인**: ``LocationRepositoryProtocol/fetchLocations(caseId:)`` 실패
- **대응**: ``TrackingFeature``에서 .locationsLoaded([])로 폴백하여 빈 상태 유지

### 예외 상황 2: CCTV 조회 실패
- **증상**: 결과 화면에서 CCTV 목록이 비어있고 EmptyState가 노출됨
- **원인**: ``CCTVAPIService/fetchCCTVByPolygon(_:)`` 실패 또는 응답 파싱 실패
- **대응**: TrackingFeature에서 .cctvResponse(.failure(_)) 처리 시 state.cctvMarkers = []로 폴백, ``TrackingResultScreen``에서 ``TimeLineEmptyState`` 노출

---

## 9. 기능 한계 및 주의사항

- 에러 UX 제한: 실패 시 사용자에게 원인(네트워크/쿼터/서버 오류 등)을 구체적으로 안내하지 않습니다 (현재는 empty fallback 중심).
- 폴리곤 정렬 없음: 선택 순서 그대로 폴리곤을 구성하므로, 선택 순서가 교차하면 시각화가 직관적이지 않을 수 있습니다.

---

## 10. 향후 개선 사항

### 기술 부채

- 별도의 네이버 맵 ``TrackingNaverMapView``를 현재 사용중 / 추후, Naver Map SDK를 사용하는 지도 화면을 ``NaverMapView`` 하나에 책임별로 프로토콜을 채택해, 점진적 기능 확장이 가능하도록 리팩토링 권장
- TrackingNaverMapView.Coordinator의 마커/오버레이 업데이트 책임 분리(Manager 추출) 검토

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| --- | --- |
| 담당자 | 이민재 (iOS Developer) |
| 관련 문서 | (관련 문서 링크) |

---

## Topics

### Core Components
- ``TrackingView``
- ``TrackingFeature``

### UI Components

메인 뷰에서 바로 이어지는 하위 뷰 입니다.
- ``TrackingSelectionScreen``
- ``TrackingResultScreen``
  
네이버 맵 SDK를 의존하고 있는 지도 뷰 입니다.
- ``TrackingNaverMapView``

선택/결과 화면의 UI 구성 요소입니다.
- ``CCTVSelectionPanel``
- ``CCTVSlotRow``
- ``TrackingResultMapPreview``
- ``TrackingResultExpandedMapView``

### Data Models
추적 기능에서 사용되는 데이터 모델입니다.
- ``Location``
- ``CCTVMarker``
- ``VWorldPolygonRequestDTO``
- ``VWorldError``
