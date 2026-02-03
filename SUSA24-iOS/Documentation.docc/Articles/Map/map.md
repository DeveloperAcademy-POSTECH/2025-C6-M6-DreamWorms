# 지도 기능 (Map Feature)

지도를 통해 사건 위치와 인프라(기지국, CCTV)를 시각화하고, 수사 정보를 탐색하는 핵심 기능입니다.

> 📅 **작성일**: 2026.01.26  
> 👤 **작성자**: 김무찬(Moo)  
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명
- **Map Feature (지도 기능)**

### 기능 정의

지도 기능은 **Redux 패턴(MapFeature)** 의 상태 관리와 **Naver Map SDK**의 명령형 제어를 연결하는 구조로 설계되었습니다.

#### 설계 배경
*   **SwiftUI (선언형)**: "지도에 무엇(What)이 표시되어야 하는가"를 `State`로 정의합니다.
*   **Naver Map (명령형)**: "어떻게(How) 그릴 것인가"를 `MapFacade`가 제어합니다.

이 구조를 통해 뷰는 복잡한 지도 제어 로직(카메라 이동, 마커 렌더링 등)을 알 필요 없이, 단순히 상태를 변경하는 것만으로 지도를 조작할 수 있습니다. 각 객체의 상세 역할은 **[7. 파일 구조 및 컴포넌트 명세]** 섹션에서 다룹니다.

> TIP: 각 객체가 주고받는 메시지의 상세한 순서와 흐름은 **[4. 기능 전체 흐름 (Sequence Diagrams)]** 섹션에서 다룹니다.

### 도입 목적
- **파편화된 정보의 시각적 통합**: 텍스트로 분산되어 있던 피의자 위치 로그와 주변 인프라(CCTV, 기지국)를 하나의 지도 인터페이스에 레이어링하여, 수사관이 직관적으로 상황을 인지할 수 있도록 합니다.

---

## 2. 기능 적용 범위

### 사용 위치 (Entry Points)
본 기능은 다음 화면 및 상황에서 동작합니다.

1.  **MainTab > MapScene**: 메인 탭의 지도 화면 (기본 진입)
2.  **검색 결과 이동**: ``SearchFeature``에서 검색 결과 선택 시 ``MapDispatcher``를 통해 지도 이동
3.  **타임라인 연동**: ``TimeLineFeature``에서 특정 시점/위치 선택 시 해당 좌표로 포커싱

### 사용자 관점 동작 조건 (User Scenarios)

1.  **진입 및 초기화 (Initialization)**
    -   **초기 렌더링**: 화면 진입 시 ``MapConstants/defaultZoomLevel``을 기준으로 ``NMCameraUpdate``가 수행되며, ``MapFeature/Action/startObservingLocations`` 액션을 통해 CoreData 및 API의 위치 데이터 변경을 구독합니다.
    -   **현위치 트래킹**: 위치 권한 승인 시, '내 위치' 버튼을 통해 카메라를 사용자 좌표로 즉시 동기화합니다.
    -   ``SearchFeature``나 ``TimelineFeature`` 등 외부 진입 시에는 ``MapDispatcher``라는 단일 진입점을 통해서만 명령을 수신하여, 상태 동기화 문제를 방지합니다.

2.  **지도 조작 및 탐색 (Navigation)**
    -   **Lazy Loading**: 카메라 이동이 멈추면 현재 화면 영역(Bounds)에 있는 인프라 데이터(CCTV, 기지국)를 자동으로 불러옵니다.
    -   **Zoom Level Optimization**: 지도를 넓게 축소하면 성능 최적화를 위해 기지국 및 CCTV 마커가 자동으로 숨겨집니다.
    -   **CCTV Fetching**: CCTV 영상 데이터는 일정 수준 이상 확대했을 때만 조회를 시도하여 불필요한 데이터 소모를 줄입니다.

3.  **인터랙션 및 정보 확인 (Interaction)**
    -   **마커 선택**: 
        -   **User Pin**: 하단에 ``PlaceInfoSheet``를 띄워 상세 정보를 표시하고, 수정/삭제 액션을 제공합니다.
        -   **Infrastructure**: 기지국 마커 선택 시, 해당 기지국이 커버하는 반경을 **``Circle Overlay``** 로 시각화하고, 방문 빈도를 뱃지로 표시합니다.
    -   **임의 위치 탐색 (Reverse Geocoding)**:
        -   마커가 없는 빈 공간을 탭(``MapFeature/Action/mapTapped(_:)``)하면 **``Idle Pin``** 이 생성됩니다.
        -   생성된 좌표를 기반으로 **Kakao Local API**를 호출하여 행정 주소를 조회하고, 결과를 시트에 표시합니다.
        
> Warning:
> 빈 공간 탭 시 수행되는 Reverse Geocoding 로직은 Kakao Local API를 사용합니다. 
> 과도한 호출을 방지하기 위해 ``MapFeature`` 내부적으로 요청 디바운싱 처리가 되어 있지는 않으나, 시트가 열려있는 상태에서의 중복 탭은 UI 레벨에서 제한됩니다.

4.  **레이어 및 필터 제어 (Layers & Overlays)**
    -   **Visual Range**: 지도의 표시 반경(Coverage)을 설정하여 데이터 밀집도를 조절합니다.
    -   **Infra Layer**: CCTV, 기지국 레이어를 개별적으로 On/Off 할 수 있어, 복잡한 지도 화면에서 원하는 정보만 선별하여 볼 수 있습니다.

---

## 3. 화면 흐름도 (Screen Flow)

![맵 스크린 플로우](map-screen-chart-diagram.svg)

### 주요 화면 흐름 상세

`사건 리스트뷰(CaseListScene)`에서 사건을 선택하여 `지도 뷰(MapScene)`으로 진입합니다. 이를 기점으로 다음과 같이 화면이 분기됩니다.

- **Full Screen (Navigation Push)**: 화면의 컨텍스트가 완전히 전환되는 기능입니다.
  - **``SearchView``**: 검색바를 터치하여 진입하며, 장소 검색 및 선택을 수행합니다.
  - **``CameraView``**: 스캔 버튼을 터치하여 진입하며, AR/Vision 기능을 수행합니다.

- **Sheet**: 지도 컨텍스트를 유지하면서 추가 정보를 제공하는 기능입니다.
  - **``PlaceInfoSheet``**: 빈 곳이나 핀을 터치했을 때 표시되는 장소 상세 정보 시트입니다.
  - **``TimeLineView``**: 기지국 마커를 터치했을 때, 해당 기지국의 로그를 보여주는 타임라인 시트입니다.
  - **``MapLayerContainer``**: 레이어 버튼을 통해 호출되며, 지도/인프라 레이어 옵션을 설정합니다.

> Tip:
> `MapScene`은 다양한 기능으로 연결되는 **Hub** 역할을 수행합니다. 기능을 추가할 때 전환 방식을 결정하는 기준은 **'지도의 문맥(Context) 유지 필요성'** 으로 보면 되겠죠.
> *   **독립적인 화면**: 검색이나 카메라 촬영처럼 지도와 독립적인 작업 흐름이 필요할 때 사용합니다. (`Coordinator` 패턴 사용)
> *   **맵과 공존하는 시트 형태**: 상세 정보 확인이나 옵션 변경처럼 지도를 보면서 작업해야 할 때 사용합니다. (`SwiftUI .sheet` 및 `State` 바인딩 사용)

---

## 4. 기능 전체 흐름 (Sequence Diagrams)

### 4.1 핵심 시퀀스 다이어그램
사용자의 지도 조작(터치)부터 데이터 처리, 그리고 화면 갱신까지의 전체 사이클을 나타냅니다. **SwiftUI(View)** 와 **UIKit(Map SDK)** 간의 데이터 흐름이 **Redux Store** 를 중심으로 순환하는 구조입니다.

![맵 시퀀스 전체](map-sequence-diagram.svg)

### 4.2 흐름 설명

본 아키텍처는 **단방향 데이터 흐름(Unidirectional Data Flow)** 을 엄격하게 따릅니다.

1.  **이벤트 감지 (Event Phase)**
    *   ``NMFMapView``에서 발생한 터치 이벤트는 ``MapTouchHandler``가 1차적으로 수신합니다.
    *   핸들러는 이를 가공하지 않고 즉시 ``MapView``로 전달하며, ``MapView``는 이를 **Action**으로 변환하여 ``MapFeature``(Store)에 보냅니다.
    *   비즈니스 로직(API 호출, 유효성 검사 등)은 모두 ``MapFeature`` 내부에서 수행됩니다.

2.  **렌더링 동기화 (Rendering Phase)**
    *   Action에 의해 ``State``가 변경되면, ``MapView``는 이를 감지합니다.
    *   SwiftUI의 라이프사이클에 따라 ``updateUIView``가 호출되면, 변경된 상태값을 ``NaverMapView``(Bridge)에 주입합니다.
    *   ``MapFacade``와 하위 매니저들은 새로운 상태값과 현재 지도의 상태를 비교(Diff)하여, 필요한 부분만 SDK에 반영합니다.

### 4.3 외부 명령 흐름 (Dispatcher Flow)
검색(``SearchFeature``)이나 타임라인(``TimelineFeature``) 등 외부 모듈에서 지도를 제어할 때는 **직접 참조 대신 ``MapDispatcher``를 통한 간접 제어** 방식을 사용합니다.

![맵 시퀀스 전체](map-dispatcher-sequence-diagram)


### 흐름 설명
1.  **명령 발행 (Publish)**: 외부 뷰는 ``MapDispatcher``에 요청(``RequestType``)을 할당합니다.
2.  **명령 구독 (Subscribe)**: ``MapView``는 `.onChange`를 통해 요청을 감지하고, 즉시 Reducer의 **Action**으로 변환합니다.
3.  **상태 반영**: 이후 과정은 4.1의 **렌더링 동기화 Phase**와 동일하게 동작하여 지도를 이동시킵니다.

> Tip:
>
> 외부 모듈(검색, 홈 등)에서 새로운 지도 제어 동작이 필요할 때는 다음 패턴을 따르세요.
> 1.  ``MapDispatcher/RequestType`` 열거형에 새로운 케이스(예: `.moveToUserLocation`)를 정의합니다.
> 2.  ``MapView``의 `.onChange(of: dispatcher.request)` 블록에서 해당 케이스를 처리하는 코드를 추가합니다.
> 이렇게 하면 뷰 간의 직접적인 의존성 없이 지도 기능을 안전하게 확장할 수 있습니다.

---

## 5. 상태 다이어그램 (State Diagram)

`MapFeature.swift`의 상태 변수 정의와 이에 따른 화면 모드 전환(State Transition) 명세입니다.

### 5.1 상태 변수 정의 (State Variables)
``MapFeature/State``에 정의된 주요 Boolean 상태 변수들입니다. 이 변수들의 값(`true`/`false`)에 따라 화면의 구성과 사용자 인터랙션이 결정됩니다.

| Variable Name | Description | Available Interactions |
| :--- | :--- | :--- |
| **``isTimelineSheetPresented``** | **초기 진입 상태** (타임라인 활성화) | • 타임라인 스크롤 <br> • 기지국 마커 탭 → 포커싱 이동 |
| **``isPlaceInfoSheetPresented``** | 장소 상세 정보 조회 | • 지도 조작 제한됨 <br> • '핀 추가' 버튼 → `PinWrite` 전이 |
| **``isPinWritePresented``** | 핀 추가/수정 (모달) | • **지도 조작 불가** <br> • 저장/취소만 가능 |
| **``isNoteWritePresented``** | 형사 노트 작성 (모달) | • **지도 조작 불가** <br> • 저장/취소만 가능 |
| **``isMapLayerSheetPresented``** | 레이어 설정 (오버레이) | • 토글 스위치 조작 |

> Note:
> *   **초기 상태(Initial State)**: 앱 실행 시 ``isTimelineSheetPresented``만 **true**이고 나머지는 false입니다.
> *   **Idle 상태**: 위 변수들이 모두 **false**인 상태(`!isAnyMapBottomPanelVisible`)를 의미하며, 이 때 지도를 넓게 탐색할 수 있습니다.

### 5.2 상태 다이어그램 (Visual Diagram)

![맵 상태 다이어그램](map-state-diagram.svg)

### 5.3 주요 전이 상세 (Transition Details)

*   **Idle / isTimelineSheetPresented → isPlaceInfoSheetPresented**
    *   **Action**: ``MapFeature/Action/mapTapped(_:)``
    *   **Effect**: ``MapFeature/State/selectedCoordinate`` 업데이트, ``isPlaceInfoSheetPresented`` = true
*   **isPlaceInfoSheetPresented → Idle** (닫기)
    *   **Action**: ``MapFeature/Action/hidePlaceInfo(shouldMinimizeTimeline:shouldDeselectMarker:)``
    *   **Effect**: ``isPlaceInfoSheetPresented`` = false, 타임라인 최소화 (`Idle`) 상태로 전환
*   **isTimelineSheetPresented ↔ Idle**
    *   **Action**: 사용자 제스처 (Sheet Drag Up/Down) 또는 기지국 마커 탭
    *   **Effect**: 시트를 내리면(`Short`) 타임라인 비활성화, 올리면(`Mid/Large`) 활성화되어 상태가 동기화됩니다.
*   **Layer Sheet Toggle (State Preservation)**
    *   **Action**: 레이어 닫기 버튼
    *   **Effect**: `isMapLayerSheetPresented`만 `false`로 변경되며, 기존의 타임라인 표시 상태(`isTimelineSheetPresented`)는 유지됩니다.


### 5.4 상태 동기화 파이프라인 (State Sync Pipeline)
새로운 데이터가 지도에 표시되기까지 총 4단계의 명시적인 연결이 필요합니다.

1.  **State Definition**: ``MapFeature/State``에 UI에 표시할 데이터를 정의합니다. (Single Source of Truth)
2.  **Data Packing**: ``NaverMapView/updateUIView(_:context:)``에서 변경된 State를 ``MapFacade/LayerData``라는 DTO로 변환합니다.
3.  **Facade Update**: 변환된 데이터를 ``MapFacade/update(...)``에 전달합니다.
4.  **Manager Execution**: Facade는 데이터를 적절한 `Manager`에게 분배하고, **Diff 알고리즘**을 수행하여 실제 마커 객체(``NMFMarker``)를 생성/삭제합니다.

> 현재 구조는 데이터 흐름이 명확한 대신, State 속성이 추가될 때마다 4단계의 코드를 모두 수정해야 하는(Shotgun Surgery) 단점이 있습니다.
> *   **현재**: Manual Wiring (State -> LayerData -> Facade -> Manager)

> TIP:   **개선 방향**: Facade가 State의 변화를 직접 구독(Subscribe)하거나, 제네릭(Generic)한 렌더러를 도입하여 보일러플레이트 코드를 줄이는 방향으로 리팩토링을 고려할 수 있습니다.

---

## 6. 의존성 다이어그램 (Dependency Diagram)

Presentation 레이어와 NaverMap(Utility) 레이어의 역할 분리를 유지하면서, 내부 비즈니스 로직(Controller, Manager 등)의 상호작용을 나타냅니다.

![맵 의존성 다이어그램](map-dependency-diagram.svg)

---

## 7. 파일 구조

```
Sources/
├── 📁 Presentation/
│    └── 🗂️ MapScene/
│         ├── 🗂️ Enum/
│         │    ├── CCTVFetchStatus.swift         // CCTV 데이터 요청 상태
│         │    ├── CoverageRangeMetadata.swift   // 커버리지 반경 메타데이터
│         │    ├── CoverageRangeType.swift       // 기지국 커버리지 타입
│         │    └── MapFilterType.swift           // 지도 필터 타입 (기지국/CCTV 등)
│         ├── 🗂️ Model/
│         │    ├── CCTVMarker.swift              // CCTV 마커 모델
│         │    ├── CellMarker.swift              // 기지국 마커 모델
│         │    ├── Location.swift                // 위치 공통 모델
│         │    ├── MapBounds.swift               // 지도 영역 바운더리
│         │    ├── MapCoordinate.swift           // 좌표 모델
│         │    └── PlaceInfo.swift               // 장소 상세 정보
│         ├── 🗂️ SubView/
│         │    ├── MapFilterButton.swift         // 필터 버튼 UI
│         │    ├── MapHeader.swift               // 상단 헤더 뷰
│         │    ├── MapLayerContainer.swift       // 레이어 컨테이너
│         │    ├── MapLayerSettingSheet.swift    // 레이어 설정 바텀시트
│         │    ├── MapSheetPanel.swift           // 하단 정보 패널
│         │    └── PlaceInfoSheet.swift          // 장소 상세 시트
│         ├── MapFeature.swift                   // [Core] TCA Reducer (비즈니스 로직)
│         └── MapView.swift                      // [UI] 메인 지도 화면
└── 📁 Util/
     └── 🗂️ NaverMap/
          ├── 🗂️ Base/
          │    └── NMConstants.swift             // 지도 상수 (줌 레벨, 애니메이션 등)
          ├── 🗂️ Cache/
          │    ├── MarkerImageCache.swift        // 마커 이미지 캐싱
          │    └── RangeOverlayImageCache.swift  // 커버리지 오버레이 이미지 캐싱
          ├── 🗂️ Component/
          │    └── MarkerImage.swift             // 마커 이미지 생성기
          ├── 🗂️ Controller/
          │    ├── MapCameraController.swift     // 카메라 이동/줌 제어
          │    └── MapLocationController.swift   // 사용자 위치 추적/권한 관리
          ├── 🗂️ DTO/
          │    └── CellStationDTO.swift          // 기지국 데이터 전송 객체
          ├── 🗂️ Extensions/
          │    ├── MapBounds+.swift              // 바운더리 변환 확장
          │    ├── NMGLatLng+.swift              // 좌표 변환 확장
          │    └── NMGLatLngBounds+Coverage.swift // 커버리지 영역 계산
          ├── 🗂️ Facade/
          │    └── MapFacade.swift               // [Core] 지도 제어 통합 인터페이스
          ├── 🗂️ Manager/
          │    ├── CaseLocationMarkerManager.swift // [Case] 사건/사용자 핀 관리
          │    └── InfrastructureLayerManager.swift // [Shared] 기지국/CCTV 관리
          ├── 🗂️ Utility/
          │    ├── MapDataService.swift          // 데이터 변환 및 해시 계산
          │    ├── MapLayerUpdater.swift         // 레이어 변경 감지 및 업데이트
          │    └── MapTouchHandler.swift         // 터치 이벤트 라우팅
          ├── MapDispatcher.swift                // 외부 모듈 통신 브릿지
          └── NaverMapView.swift                 // NMFMapView 래퍼 (UIViewRepresentable)
```

### 📃 상세 컴포넌트 명세


### A. Presentation Layer (UI & State)
SwiftUI 기반의 뷰와 상태 관리를 담당합니다.
| 컴포넌트 | 역할 및 책임 (Responsibility) |
| :--- | :--- |
| ``MapFeature`` | 지도의 모든 상태(데이터, UI 플래그)를 관리하는 리듀서 입니다. 비즈니스 로직의 중심 역할을 합니다. |
| ``MapView`` | SwiftUI 화면입니다. ``MapFeature``의 상태를 구독하여 ``NaverMapView``와 하단 시트들을 배치합니다. |
| ``NaverMapView`` | SwiftUI와 UIKit(NMFMapView) 사이의 어댑터입니다. SwiftUI State를 선언적으로 받아 ``MapFacade``에 전달합니다. |
| ``MapDispatcher`` | 외부 모듈(검색, 타임라인 등)에서 지도를 제어하기 위한 통신 채널입니다. |

### B. Map Core & Logic (Control Tower)
지도 제어의 중추적인 역할을 수행하며, 데이터를 가공하고 하위 객체들을 지휘합니다.
| 컴포넌트 | 역할 및 책임 (Responsibility) |
| :--- | :--- |
| ``MapFacade`` | 지도 제어의 총괄자입니다. `NMFMapView` 인스턴스를 소유하지 않고, 메서드 호출 시점에 받아 로직을 수행합니다. |
| ``MapLayerUpdater`` | 화면에 표시될 레이어(LayerData)를 분석하여 각 매니저에게 업데이트 명령을 내리는 중간 허브입니다. |
| ``MapDataService`` |  데이터 변환, 해시 계산, 클러스터링 알고리즘 등 순수 로직을 담당합니다. |
| ``MapTouchHandler`` |  터치 이벤트를 수신하고, 이를 적절한 비즈니스 로직으로 라우팅합니다. |

### C. Render Managers & Controllers (Execution)
실제 지도를 조작하고 마커를 그리는 실행 객체들입니다.
| 컴포넌트 | 역할 및 책임 (Responsibility) |
| :--- | :--- |
| ``MapCameraController`` | 좌표 이동, 줌 레벨 조정, 애니메이션 등 카메라 제어를 전담합니다. |
| ``MapLocationController`` | 현위치 추적 및 위치 권한 상태를 관리합니다. |
| ``InfrastructureMarkerManager`` | 모든 사건에서 공통적으로 사용되는 **인프라 데이터(기지국, CCTV)** 를 관리합니다. 배경(Context) 정보를 제공합니다. |
| ``CaseLocationMarkerManager`` | 현재 **사건에 종속된 데이터(집/회사/핀 등)** 를 관리합니다. 인터랙션과 선택 상태를 처리합니다. |

---

## 8. 예외 상황 및 대응 기준

현재 구현된 예외 처리 현황과, 향후 개선이 필요한 우선순위 항목입니다.

### A. 현재 구현된 예외 처리 (Implemented)

코드 레벨에서는 `try-catch` 및 `Error State`가 정의되어 있으나, 일부 UI 피드백이 누락되어 있습니다.

#### 1. CCTV 조회 실패
API 호출 실패 시 에러 메시지를 State에 저장하지만, 사용자에게 표시되지 않습니다.
- **파일**: `MapFeature.swift` (Line 475 ~ 476)

```swift
// MapFeature.swift
case let .fetchCCTV(bounds):
    return .task { [cctvService] in
        do {
            let response = try await cctvService.fetchCCTVByBox(requestDTO)
            // ... 성공 처리 ...
        } catch {
            return .cctvFetchFailed(error.localizedDescription)
        }
    }
```

> IMPORTANT:
> 에러 상태(`.cctvFetchFailed`)는 정의되어 있으나, `MapView`에서 이를 감지하여 **Toast 메시지** 등을 띄우는 로직이 구현되지 않았습니다. 사용자는 데이터 로딩 실패 여부를 알 수 없습니다.

#### 2. 기지국 데이터 로딩 실패
앱 초기 구동 시 기지국 JSON 파싱에 실패하면 빈 배열을 반환합니다.
- **파일**: `MapFeature.swift` (Line 264 ~ 265)

```swift
// MapFeature.swift
do {
    let cellMarkers = try await CellStationLoader.loadFromJSON()
    return .loadCellMarkers(cellMarkers)
} catch {
    // 에러 로그 없이 빈 화면 유지
    return .loadCellMarkers([])
}
```

> TIP:
> 개발 모드(`DEBUG`)에서는 `print`나 `fatalError`를 통해 JSON 형식이 잘못되었음을 알리는 것이 좋습니다.

#### 3. 장소 정보 조회 실패 (Kakao API)
지도 탭 시 장소 정보를 가져오지 못하면 빈 텍스트로 폴백(Fallback)합니다.
- **파일**: `MapFeature.swift` (Line 345 ~ 351)

```swift
// MapFeature.swift
} catch {
    // 사용자에게 "주소 없음" 등의 안내 문구가 필요함
    return .showPlaceInfo(PlaceInfo(title: "", jibunAddress: "", ...))
}
```

---

> IMPORTANT: 
> `MapLocationController`에서 권한 변경을 감지하지만, **거부(Denied)** 상태일 때 아무런 처리를 하지 않습니다.
> - **권장 대응**: `CLAuthorizationStatus`가 `.denied`일 때, **Alert을 띄워 설정 화면으로 이동**하도록 유도하는 로직을 반드시 추가해야 합니다.

> WARNING:
> 핀 삭제나 저장 실패 시(CoreData 오류 등), UI는 성공한 것처럼 보이거나 아무 반응이 없습니다.
> - **권장 대응**: 데이터 조작에 실패했을 경우, **Alert을 통해 사용자에게 실패 사실을 알리고 재시도를 요청**해야 합니다.

---

## 9. 기능 한계 및 주의사항

본 섹션은 현재 시스템의 외부 의존성과 구조적 한계, 그리고 향후 개선이 필요한 기술 부채(Technical Debt)를 기술합니다.

### 9.1 외부 서비스 의존성

지도 모듈은 기능 구현을 위해 총 4개의 외부 서비스에 의존하고 있습니다. API 서버의 상태에 따라 서비스가 제한될 수 있음을 유의해야 합니다.

| 의존성 | 용도 | 위험 요소 (Risks) | 대응 (Reference) |
| :--- | :--- | :--- | :--- |
| **Naver Maps SDK** | 지도 렌더링 (Base Map) | SDK 업데이트 호환성, 라이선스 정책 변경 | `MapFacade`로 의존성 격리 |
| **VWorld API** | CCTV 영상/메타데이터 | API 서버 장애 시 데이터 미노출 | **[8.A.1]** CCTV 조회 실패 참조 |
| **Kakao Local API** | 좌표 ↔ 주소 (Reverse) | 일일 쿼터 초과, 오지 데이터 부재 | **[8.A.3]** 장소 정보 조회 실패 참조 |
| **Naver Geocoding** | 주소 → 좌표 (Forward) | 주소 변환 실패, 쿼터 초과 | 변환 실패 Alert 제공 |

---

### 9.2 데이터 처리 전략 및 잠재적 한계

대량의 데이터를 효율적으로 다루기 위해 적용된 전략과, 그로 인한 기능적 기회비용(Trade-off)입니다.

#### A. 지연 로딩 (Lazy Fetching)
*   **Technical Spec**: 카메라 이동 종료 시점(`cameraIdle`)에만 API를 호출합니다.
*   **Trade-off**: 사용자가 지도를 빠르게 훑어보는(Scanning) 동안에는 데이터가 표시되지 않으며, 멈춘 직후에 마커가 나타나는 딜레이가 발생합니다.

#### B. 렌더링 최적화 (LOD Strategy)
*   **Technical Spec**: 
    *   **Marker Visibility**: 줌 레벨 **8.0** (``MapConstants/markerVisibilityThreshold``) 미만에서는 마커를 렌더링하지 않습니다.
    *   **CCTV Fetching**: 줌 레벨 **14.0** (``MapConstants/minZoomForCCTV``) 이상에서만 상세 데이터를 요청합니다.

*   **Trade-off**: 전국 단위의 데이터 분포를 한눈에 파악하기 어렵습니다.

#### C. 메모리 관리 (Caching)
*   **Technical Spec**: FIFO 방식으로 최대 **3,000개**의 마커 인스턴스를 유지합니다.
*   **Trade-off**: CCTV 밀집 지역 탐색 시, 화면 내 마커라도 캐시에서 밀려나면 재요청 오버헤드가 발생할 수 있습니다.

---

## 10. 향후 개선 사항

### A. 기능 고도화

*   **API Fallback 구축**: 주 API(예: VWorld) 장애 시 대체 가능한 서비스(Google Maps, OSM 등)로 자동 전환하는 로직 도입 검토.
*   **지능형 프리페칭 (Intelligent Prefetching)**: 이동 속도와 방향을 계산하여, 카메라가 멈추기 전에 진행 방향의 데이터를 미리 로딩하는 Throttling 기반 로직 도입.
*   **Viewport-Aware Caching**: 단순 FIFO 캐싱 대신, **현재 화면에 보이는 마커는 유지**하는 LRU 알고리즘으로 개선하여 깜빡임(Flickering) 방지.
*   **서버 사이드 클러스터링(서버 도입시)**: 클라이언트 렌더링 부하를 원천적으로 해결하기 위해, 줌 레벨별로 서버에서 이미 클러스터링된 데이터를 내려주는 방식 검토.

### B. 기술 부채

#### 1) MapFeature.swift의 모듈화 (God Reducer 문제)
현재 `MapFeature.swift` 파일 하나가 약 1,000줄에 달합니다. 지금은 괜찮지만, 기능이 조금만 더 붙으면 유지보수가 어려워 질 수 있습니다.
- **제안**: `MapFeature`를 메인으로 두되, **하위 리듀서(Sub-Reducer)를 분리**하여 조립(Composition)하는 구조로 리팩토링하면 좋을 것 같습니다.

#### 2) 위치 탐색 알고리즘 최적화
현재 `findExistingLocation` 함수에서 사용자가 탭한 위치 근처의 핀을 찾을 때, `locations` 배열 전체를 **순차 탐색(Loop)** 하고 있습니다.
- **문제**: 현재 데이터 양(수백 개 수준)에서는 전혀 문제없습니다. 하지만 핀이 수천 개(예: 전국 데이터)로 늘어나면 탭 반응 속도가 느려질 수 있습니다.
- **제안**: 추후 데이터가 늘어나면 **QuadTree** 같은 공간 분할 알고리즘을 도입하거나, 화면에 보이는 영역(Bounds) 내의 데이터만 탐색하도록 최적화가 필요합니다. 

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| :--- | :--- |
| **담당자** | 김무찬 (iOS Developer) |
| **관련 문서** | [Naver Maps SDK Guide](https://navermaps.github.io/ios-map-sdk/guide-ko/), [VWorld CCTV API 2.0 Reference,  ](https://www.vworld.kr/dev/v4dv_2ddataguide2_s002.do?svcIde=utiscctv) [Kakao Rest API](https://developers.kakao.com/docs/latest/ko/local/dev-guide) | 
