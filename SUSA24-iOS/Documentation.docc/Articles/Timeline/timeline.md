# 타임라인 기능 (Timeline Feature)
수집된 위치 데이터를 날짜별 그룹화 · 연속 체류 분석 · TOP3 색상 시각화로 재구성하여, 바텀시트 형태로 지도와 동시에 탐색할 수 있는 위치 이력 타임라인입니다.

> 📅 **작성일**: 2026.02.10
> 👤 **작성자**: 유경모 (Gyeongmo)
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명

- **Timeline Feature (타임라인 바텀시트)**

### 기능 정의

Timeline Feature는 ``MainTabFeature``(SSOT)에서 전달받은 위치 데이터를 ``TimeLineFeature``가 **날짜별 그룹화**, **연속 체류 그룹 생성**, **TOP3 주소 색상 매핑**으로 재가공하여, ``TimeLineView`` 바텀시트에서 시각화하는 기능입니다.

``TimeLineView``는 MapScene의 지도 위에 **항상 표시되는 바텀시트**로 동작하며, `PresentationDetent`를 통해 Short(73px) / Mid(40%) / Large(전체) 높이를 전환할 수 있습니다.

사용자는 타임라인 내 위치 셀을 탭하여 ``MapDispatcher``를 통해 **지도 카메라를 즉시 이동**시킬 수 있고, 반대로 지도에서 기지국 마커를 탭하면 ``MapDispatcher``의 `.focusCellTimeline` 요청을 통해 **기지국 타임라인 모드**로 전환됩니다.

검색 기능은 **250ms 디바운싱** 기반으로 주소 키워드를 필터링하여 결과를 제공합니다.

### 도입 목적

- **시간 축 기반 위치 추적**: 지도의 공간 축(Where)에 시간 축(When)을 결합하여, 피의자의 이동 동선을 시간 순서로 파악할 수 있도록 합니다.
- **체류 패턴 가시화**: 연속 체류 그룹화와 TOP3 색상 코딩을 통해, 가장 오래 머문 장소와 반복 방문 패턴을 직관적으로 식별할 수 있도록 합니다.
- **지도-타임라인 양방향 연동**: 타임라인 셀 탭 → 지도 이동, 기지국 마커 탭 → 타임라인 필터링의 양방향 인터랙션을 통해 수사 정보 탐색 효율을 극대화합니다.

---

## 2. 기능 적용 범위

### 사용 위치

1. **MainTab > MapScene**: 메인 탭의 지도 화면 바텀시트 (기본 진입, 항상 표시)
2. **기지국 마커 탭 시**: 기지국 타임라인 모드로 전환 (``MapDispatcher`` 연동)

### 사용자 관점 동작 조건

1. 사용자가 사건을 선택하여 지도 탭에 진입하면 ``MainTabFeature``가 SSOT를 통해 위치 데이터를 로드하고, ``TimeLineFeature``에 `.updateData()` 액션으로 전달합니다.
2. ``TimeLineFeature``는 ``LocationGroupedByDate``의 `groupByDate()` 메서드로 데이터를 날짜별 그룹화하고, TOP3 주소를 계산하여 색상을 매핑합니다.
3. 사용자가 **위치 셀을 탭**하면 ``TimeLineFeature``가 ``MapDispatcher``에 `.moveToLocation(coordinate:)` 요청을 전송하고, 지도 카메라가 해당 좌표로 이동합니다.
4. 사용자가 **지도에서 기지국 마커를 탭**하면, ``MapDispatcher``의 `.focusCellTimeline(cellKey:title:)` 요청을 통해 ``TimeLineFeature``가 **기지국 타임라인 모드**로 전환됩니다.
5. 사용자가 **검색바에 키워드를 입력**하면, 250ms 디바운스 후 주소 기반 필터링 결과가 표시됩니다.

---

## 3. 화면 흐름도 (Screen Flow)

![타임라인 화면 흐름도](timeline-screen-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

![타임라인 시퀀스 다이어그램](timeline-sequence-diagram.svg)

### 4.2 컴포넌트 상호작용 다이어그램

``TimeLineView``의 body가 모드(전체/기지국)와 데이터 상태(비어있음/검색 결과 없음/데이터 있음)에 따라 분기되는 구조입니다.

![타임라인 컴포넌트 다이어그램](timeline-component-diagram.svg)

### 4.3 흐름 설명

1) **초기 데이터 로딩 (SSOT)**
    - ``MainTabView``가 `.onAppear`에서 ``MainTabFeature``의 `.onAppear` 액션을 전송합니다.
    - ``MainTabFeature``는 ``CaseRepository``의 `fetchAllDataOfSpecificCase()`를 호출하여 사건 정보와 위치 데이터를 로드합니다.
    - 동시에 `.startLocationObserver` 액션을 통해 ``LocationRepository``의 `watchLocations(caseId:)` AsyncStream을 구독합니다.
    - CoreData에 새 위치가 저장될 때마다 `.locationsUpdated([Location])` 액션이 자동 발생합니다.

2) **타임라인 동기화**
    - ``MainTabView``의 `.onChange(of: store.state.locations)`에서 ``TimeLineFeature``에 `.updateData(caseInfo:locations:)` 액션을 전송합니다.
    - ``TimeLineFeature``의 Reducer가 ``LocationGroupedByDate``의 `groupByDate()` 정적 메서드를 호출합니다.
    - `groupByDate()`는 내부적으로:
        1. `locationType == 2` (기지국)인 위치만 필터링
        2. 전체 위치에서 **TOP 3 주소**를 방문 빈도 기준으로 계산
        3. 날짜별(Calendar dayStart 기준)로 그룹화
        4. 각 날짜 그룹 내에서 **연속 체류 그룹** (`ConsecutiveLocationGroup`)을 생성
        5. TOP 3 랭킹에 따라 ``TimeLineColorStickState`` (`.top1` / `.top2` / `.top3` / `.normal`) 을 할당
        6. 날짜 내림차순으로 정렬

3) **위치 셀 탭 → 지도 연동**
    - ``TimeLineDetail`` 컴포넌트의 `onTap` 클로저가 ``TimeLineFeature``에 `.locationTapped(location)` 액션을 전송합니다.
    - ``TimeLineFeature``의 Reducer가 ``MapDispatcher``에 `.moveToLocation(coordinate:)` 요청을 전송합니다.
    - 동시에 `.resetDetentToMid` NotificationCenter 알림을 발송하여 바텀시트를 Mid 높이로 조절합니다.
    - ``MapView``가 `onChange(of: dispatcher.request)`에서 요청을 감지하고, 카메라를 해당 좌표로 이동시킨 뒤 `dispatcher.consume()`을 호출합니다.

4) **검색 (Debounce Pattern)**
    - ``TimeLineSearchBar``에 키워드가 입력되면 `.searchTextChanged(text)` 액션이 발생합니다.
    - Reducer는 새로운 `UUID` taskID를 생성하고 `state.searchDebounceTaskID`에 저장합니다.
    - 250ms `Task.sleep` 후 `.performSearch(text, taskID)` 액션이 발생합니다.
    - Reducer는 `state.searchDebounceTaskID == taskID`를 검증하여 **만료된 검색을 무시**합니다.
    - 유효한 검색이면 `groupedLocations` 내에서 주소 substring 필터링을 수행합니다.

5) **기지국 타임라인 모드**
    - 지도에서 기지국 마커를 탭하면 ``MapDispatcher``에 `.focusCellTimeline(cellKey:title:)` 요청이 전송됩니다.
    - ``MainTabView``의 `onChange(of: dispatcher.request)`에서 이를 감지하고:
        - PlaceInfoSheet가 열려 있으면 닫기
        - Idle Pin이 있으면 제거
        - ``TimeLineFeature``에 `.applyCellFilter(cellKey:title:)` 액션 전송
        - 바텀시트를 Mid 높이로 조절
        - `dispatcher.consume()` 호출
    - ``TimeLineFeature``는 `cellKey` (좌표 키 형식: "latitude_longitude") 기반으로 위치를 필터링하고 `state.isCellTimelineMode = true`로 전환합니다.
    - 사용자가 바텀시트를 Short으로 내리면 `.clearCellFilter` 액션이 발생하여 전체 타임라인으로 복귀합니다.

> Tip:
> 타임라인과 지도 간 통신은 모두 ``MapDispatcher``를 경유합니다.
> 새로운 연동 기능을 추가할 때는:
> 1. ``MapDispatcher/RequestType``에 새로운 케이스를 정의하고
> 2. ``MainTabView``의 `.onChange(of: dispatcher.request)` 블록에서 해당 케이스를 처리합니다.
> 이를 통해 뷰 간 직접 의존 없이 안전하게 기능을 확장할 수 있습니다.

---

## 5. 상태 다이어그램 (State Diagram)

### 5.1 상태 변수 정의 (State Variables)

Timeline Feature는 2종류의 상태로 화면을 제어합니다.

**1. Store State: TimeLineFeature.State** (데이터/필터/검색 상태)

| Variable Name | Description | Available Interactions |
| :--- | :--- | :--- |
| ``TimeLineFeature/State/caseInfo`` | 현재 사건 정보 | 헤더에 사건명/용의자 표시 |
| ``TimeLineFeature/State/locations`` | 원본 위치 데이터 배열 | groupByDate 입력값 |
| ``TimeLineFeature/State/groupedLocations`` | 날짜별 그룹화된 위치 데이터 | 타임라인 셀 렌더링 |
| ``TimeLineFeature/State/isCellTimelineMode`` | 기지국 타임라인 모드 여부 | 헤더/검색바 표시 전환 |
| ``TimeLineFeature/State/cellTimelineTitle`` | 기지국 타임라인 모드의 제목 | 기지국 이름 표시 |
| ``TimeLineFeature/State/scrollTarget`` | 스크롤 앵커 대상 (UUID triggerID) | 날짜 칩 탭 시 스크롤 이동 |
| ``TimeLineFeature/State/searchText`` | 현재 검색 키워드 | 검색바 바인딩 |
| ``TimeLineFeature/State/isSearchActive`` | 검색 활성화 여부 | 검색 UI 상태 제어 |
| ``TimeLineFeature/State/searchedGroupedLocations`` | 검색 결과 그룹 | 검색 시 대체 데이터 소스 |
| ``TimeLineFeature/State/searchDebounceTaskID`` | 디바운스 검증용 UUID | 만료된 검색 무시 |

**2. View Local State: MainTabView** (바텀시트 Detent 제어)

| Variable Name | Description | Available Interactions |
| :--- | :--- | :--- |
| selectedDetent | 현재 바텀시트 높이 | Short(73px) / Mid(40%) / Large(전체) |

**주요 Computed Properties:**

| Property | 설명 |
| :--- | :--- |
| `caseName` | `caseInfo?.name ?? ""` — 사건명 |
| `suspectName` | `caseInfo?.suspect ?? ""` — 용의자명 |
| `isEmpty` | `groupedLocations.isEmpty` — 데이터 유무 |
| `totalLocationCount` | 고유 주소 개수 |
| `isSearchResultEmpty` | `isSearchActive && searchedGroupedLocations.isEmpty` |
| `displayGroupedLocations` | 검색 활성화 시 `searchedGroupedLocations`, 아니면 `groupedLocations` |

### 5.2 상태 다이어그램 (Visual Diagram)

![타임라인 상태 다이어그램](timeline-state-diagram.svg)

### 5.3 주요 전이 상세 (Transition Details)

- **onAppear → 데이터 로딩**: ``MainTabFeature``의 SSOT를 통해 위치 데이터를 수신합니다.
- **updateData → 그룹화 완료**: ``LocationGroupedByDate/groupByDate(_:)``로 날짜별 그룹 생성 및 TOP3 계산
- **searchTextChanged → performSearch**: 250ms 디바운스 후 UUID taskID 검증을 거쳐 필터링 실행
- **applyCellFilter → 기지국 모드**: cellKey 기반 필터링 + `isCellTimelineMode = true`
- **clearCellFilter → 전체 모드**: 바텀시트 Short 전환 시 자동 해제
- **locationTapped → 지도 이동**: ``MapDispatcher``를 통한 카메라 이동 + Detent Mid 복귀
- **scrollToDate → 스크롤 앵커링**: UUID `triggerID` 기반으로 동일 날짜 재탭 시에도 스크롤 가능

---

## 6. 의존성 다이어그램 (Dependency Diagram)

![타임라인 의존성 다이어그램](timeline-dependency-diagram.svg)

---

## 7. 파일 구조

```
Sources/
├── 📁 Data/
│    └── 🗂️ Repository/
│         └── LocationRepository.swift         // watchLocations() - CoreData 실시간 변경 감지 AsyncStream
├── 📁 Presentation/
│    ├── 🗂️ MainTabScene/
│    │    ├── MainTabFeature.swift              // SSOT: startLocationObserver, locationsUpdated 액션
│    │    └── MainTabView.swift                 // .onChange(of: locations) → TimeLineFeature 동기화
│    │                                          // .sheet → DWTabBar + TimeLineView 바텀시트 관리
│    │                                          // .onChange(of: dispatcher.request) → focusCellTimeline 처리
│    └── 🗂️ TimeLineScene/
│         ├── 🗂️ Components/
│         │    ├── 🗂️ SubViews/
│         │    │    ├── TimeLineCellLocationDetail.swift  // 주소 + 시간 범위 텍스트 (HH:mm a 포맷)
│         │    │    └── TimeLineColorStick.swift          // TOP3 색상 인디케이터 (top1~normal)
│         │    ├── TimeLineBottomSheetHeader.swift        // 사건명 | 용의자 | 위치 수 헤더
│         │    ├── TimeLineDateChip.swift                 // 날짜 칩 (M.d 포맷) + TimeLineDateChipList
│         │    ├── TimeLineDetail.swift                   // 위치 카드 셀 (ColorStick + LocationDetail)
│         │    ├── TimeLineEmpty.swift                    // 빈 상태 뷰 (noCellData / searchEmpty)
│         │    ├── TimeLineScrollContentView.swift        // ScrollViewReader + 날짜별 앵커 스크롤
│         │    └── TimeLineSearchBar.swift                // DWSheetSearchBar 래핑 + 250ms 디바운스 연동
│         ├── 🗂️ Model/
│         │    ├── ConsecutiveLocationGroup.swift         // 연속 체류 그룹 모델 (address, timeRange, state)
│         │    └── LocationGroupedByDate.swift            // 날짜별 그룹 모델 + groupByDate() 정적 메서드
│         ├── TimeLineFeature.swift                      // Reducer: 그룹화 · 검색 · 필터 · 지도 연동
│         └── TimeLineView.swift                         // 바텀시트 엔트리: 모드 분기 + 컴포넌트 조합
└── 📁 Util/
     └── 🗂️ NaverMap/
          └── MapDispatcher.swift                        // 타임라인 ↔ 지도 양방향 통신 버스
```

---

## 8. 예외 상황 및 대응 기준

### 예외 상황 1: 위치 데이터 없음

- **증상**: 타임라인에 셀이 표시되지 않고 ``TimeLineEmptyState``가 노출됨
- **원인**: 해당 사건에 수집된 위치 데이터가 없음 (기지국 문자 미수신 또는 App Intent 미설정)
- **대응**: `store.state.isEmpty == true`일 때 `.noCellData` 타입의 ``TimeLineEmptyState`` 컴포넌트를 표시합니다.

### 예외 상황 2: 검색 결과 없음

- **증상**: 검색바에 키워드 입력 후 결과가 표시되지 않음
- **원인**: 입력된 키워드와 매칭되는 주소가 `groupedLocations` 내에 존재하지 않음
- **대응**: `store.state.isSearchResultEmpty == true`일 때 `.searchEmpty` 타입의 ``TimeLineEmptyState`` 컴포넌트를 표시합니다.

### 예외 상황 3: SSOT Observer 스트림 종료

- **증상**: 새 위치가 저장되어도 타임라인에 반영되지 않음
- **원인**: `watchLocations()` AsyncStream이 예기치 않게 종료됨
- **대응**: 현재 스트림 종료 시 `.stopLocationObserver` 액션만 발생하며, 재구독 로직은 미구현입니다. 앱 재시작 시 onAppear에서 다시 구독을 시작합니다.

---

## 9. 기능 한계 및 주의사항

- **기지국 데이터만 타임라인에 표시**: `groupByDate()` 내부에서 `locationType == 2` (기지국)인 위치만 필터링합니다. 사용자가 수동으로 추가한 핀(locationType != 2)은 타임라인에 표시되지 않습니다.

- **연속 체류 시간 계산의 근사치**: ``ConsecutiveLocationGroup``의 `startTime`은 실제 최초 수신 시각에서 **5분을 뺀 값**으로 설정됩니다. 이는 기지국 문자 수신 간격(보통 5분)을 감안한 근사치이며, 실제 도착 시각과 차이가 있을 수 있습니다.

- **TOP3 색상 매핑의 전역성**: TOP3 주소는 **전체 날짜**의 방문 빈도를 기준으로 계산됩니다. 특정 날짜에서는 TOP3가 아닌 주소가 색상 표시될 수 있어, 날짜별 상대 랭킹과 혼동될 수 있습니다.

- **검색 범위 제한**: 현재 검색은 `address` 필드의 substring 매칭만 지원합니다. 시간대 검색, 체류시간 기반 필터링은 미지원입니다.

- **스크롤 앵커링 기법**: `ScrollTarget`은 `dateID`가 아닌 `triggerID`(UUID)를 `Equatable` 기준으로 사용합니다. 이를 통해 같은 날짜 칩을 두 번 탭해도 스크롤이 동작하지만, 이 기법은 SwiftUI의 `scrollTo` 메커니즘에 의존하므로 iOS 버전에 따라 동작이 다를 수 있습니다.

---

## 10. 향후 개선 사항

### 기능 고도화

- **시간대 기반 검색**: 주소 외에 날짜/시간 범위로 필터링 가능하도록 검색 기능 확장
- **체류시간 기반 정렬**: 가장 오래 머문 장소 순으로 정렬하는 옵션 추가
- **날짜별 상대 TOP3**: 전역 TOP3 외에 각 날짜별 상대 랭킹 색상 옵션 제공
- **타임라인 PDF 내보내기**: 수사 보고서용 타임라인 데이터 PDF 생성 기능

### 기술 부채

- **locationType 하드코딩**: `locationType == 2`를 직접 비교하는 대신 ``LocationType`` enum을 활용하여 타입 안전성을 확보해야 합니다.
- **groupByDate() 복잡도**: 현재 `groupByDate()`는 ~50줄의 단일 함수로, TOP3 계산 + 그룹화 + 연속 그룹 생성을 모두 수행합니다. 각 단계를 독립적인 메서드로 분리하면 테스트 용이성이 향상됩니다.
- **바텀시트 Detent 하드코딩**: Short(73px), Mid(40%), Large(전체) 값이 ``MainTabView``에 직접 정의되어 있습니다. 디바이스별 최적화를 위해 설정 파일이나 enum으로 추출을 고려할 수 있습니다.

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| --- | --- |
| 담당자 | 유경모 (iOS Developer) |
| 관련 PR | [SSOT 기반 토대 구축](https://github.com/DeveloperAcademy-POSTECH/2025-C6-M6-DreamWorms/pull/50) |
| 관련 PR | [실시간 Observer 추가](https://github.com/DeveloperAcademy-POSTECH/2025-C6-M6-DreamWorms/pull/122) |
| 핵심 파일 | TimeLineFeature.swift, TimeLineView.swift, LocationGroupedByDate.swift, MainTabFeature.swift |

---

## Topics

### Core Components

타임라인의 상태 관리와 뷰 엔트리 포인트입니다.

- ``TimeLineFeature``
- ``TimeLineView``
- ``MainTabFeature``
- ``MainTabView``

### UI Components

타임라인 바텀시트를 구성하는 하위 뷰 컴포넌트입니다.

- ``TimeLineBottomSheetHeader``
- ``TimeLineSearchBar``
- ``TimeLineDateChipList``
- ``TimeLineScrollContentView``
- ``TimeLineDetail``

### Visual Indicators

위치 데이터의 시각적 표현을 담당합니다.

- ``TimeLineColorStick``
- ``TimeLineCellLocationDetail``
- ``TimeLineEmptyState``

### Data Models

타임라인에서 사용되는 데이터 모델입니다.

- ``LocationGroupedByDate``
- ``ConsecutiveLocationGroup``
- ``Location``
- ``Case``

### Communication

타임라인과 지도 간 양방향 통신을 담당합니다.

- ``MapDispatcher``
