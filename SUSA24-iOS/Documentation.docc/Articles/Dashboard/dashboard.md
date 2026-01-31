# 분석 기능 (Dashboard Feature)
수집된 위치 데이터(Location)를 기반으로 체류시간/방문빈도 Top3 랭킹과 시간대별 방문 패턴 Swift Charts를 제공하고,   
Foundation Model 기반 요약 문장(스트리밍)을 통해 인사이트를 제공하는 기능입니다.

> 📅 **작성일**: 2026.01.30
> 👤 **작성자**: 이민재 (Mini)
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명

### 기능 정의

Dashboard Feature는 ``DashboardView`` 진입 시 ``DashboardFeature``가 ``LocationRepositoryProtocol``에서 특정 케이스의 위치 데이터를 로드합니다.  

``DashboardFeature``는 로딩된 ``Location`` 데이터로 다음 화면 표시용 데이터를 구성합니다.
- 랭킹 카드 데이터: ``StayAddress`` 기반 Top3 (체류시간 / 방문빈도)
- 차트 데이터: ``CellChartData`` 기반 시간대 방문 패턴(요일 필터 포함)

초기 데이터 세팅이 완료되고 데이터가 존재하면, ``DashboardFeature``는 ``DashboardAnalysisServiceProtocol``을 통해 Foundation Model 스트리밍 분석을 요청합니다.   
이때 생성되는 요약 문장은 ``VisitDurationSummary`` 또는 ``VisitFrequencySummary``에 담기며, 항상 3줄 (줄바꿈 2개) 형식으로 생성됩니다.  

스트리밍 중간 결과는 DashboardFeature.Action.updatePartialAnalysis로 상태에 반영되고,  
스트리밍 종료 후 마지막 partial을 setAnalysisResult로 확정하여 UI에 최종 반영합니다.  

### 도입 목적

- **분석 데이터의 시각화**: 원본 위치 로그를 “랭킹(Top3) + 패턴(시간대 차트)”로 재구성해 빠르게 파악할 수 있게 합니다.
- **요약 인사이트 제공**: 단순 수치가 아닌 “어디/언제/왜 중요한지”를 상단 헤더 문장으로 요약합니다.

---

## 2. 기능 적용 범위

### 사용 위치

1. MainTabView > DashboardScene (분석 탭)
2. 랭킹 카드 탭 시 LocationOverviewScene으로 상세 화면 이동

### 사용자 관점 동작 조건

1. 사용자가 대시보드 화면에 진입하면 ``DashboardFeature``가 `LocationRepositoryProtocol.fetchLocations(caseId:)`로 위치 데이터를 로드한다.
2. 데이터 로딩이 완료되면 랭킹 섹션(``DashboardRankSection``)과 차트 섹션(``DashboardChartSection``)이 표시된다.
3. 데이터가 존재하면 Foundation Model 분석 스트리밍이 시작되고, 상단 헤더(``DashboardHeader``) 문장이 점진적으로 갱신된다.
4. 사용자가 상단 탭 (체류시간/방문빈도)을 바꾸면 탭에 맞는 랭킹과 헤더 문장이 렌더링된다.
5. 사용자가 차트의 요일 Pill을 변경하면 해당 차트의 요일 기준 데이터/요약이 갱신된다.

---

## 3. 화면 흐름도 (Screen Flow)

![분석 탭 화면 흐름도](dashboard-screen-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

![분석 탭 시퀀스 다이어그램](dashboard-sequence-diagram.svg)

### 4.2 흐름 설명

1. 이벤트 감지 (Event Phase)
    - ``DashboardView``는 .task에서 DashboardFeature.Action.onAppear(_:)를 Store로 보냅니다.
    - ``DashboardRankSection``의 Segmented Picker 탭 전환은 DashboardFeature.Action.setTab(_:)으로 전달됩니다.
    - ``DashboardChartSection``의 요일 변경은 DashboardFeature.Action.setChartWeekday(id:weekday:)로 전달됩니다.

2. 비즈니스 로직 처리 (Business Logic Phase)
    - ``DashboardFeature``는 .onAppear(caseID) 수신 시:  
        - LocationRepositoryProtocol.fetchLocations(caseId:)를 호출합니다.
        - ``LocationRepository``는 CoreData에서 ``CaseEntity`` → ``SuspectEntity`` → ``LocationEntity`` 관계로 Locations를 모아 ``Location`` 모델로 변환합니다.
    - 초기 데이터는 .setInitialData로 한 번에 반영됩니다.
    - 데이터가 존재하면 .analyzeWithFoundationModel을 통해 Foundation Model 분석 스트리밍을 시작합니다.
        - 체류시간 탭: DashboardAnalysisService.streamVisitDurationAnalysis
            - 입력: topDuration.first.address + 해당 주소의 “가장 머무를 가능성이 높은 1시간 구간”
        - 방문빈도 탭: DashboardAnalysisService.streamVisitFrequencyAnalysis
            - 입력: topFrequency.first.address + 해당 주소의 “가장 많이 방문한 날짜/요일”
    - 생성 결과는 ``VisitDurationSummary`` / ``VisitFrequencySummary``의 title에 담기며, 항상 3줄, 줄 구분은 정확히 \n 2개 규칙을 강제합니다.
    - 스트리밍 중간 결과는 updatePartialAnalysis로 반영하고, 마지막 partial을 setAnalysisResult로 확정합니다.
    - 스트리밍 실패/partial 미수신 시 analysisFailed로 전환합니다.

3. 렌더링 동기화 (Rendering Phase)    
    - State 변경 시 DashboardView는 다음을 동기화합니다.
        - ``DashboardHeader``: isAnalyzingWithFM + tab + summary 상태에 따라 진행/완료/부족 문장을 결정
        - ``DashboardRankSection``: 탭에 따라 Top3 데이터 표시, 비어 있으면 TimeLineEmptyState 노출
        - ``DashboardChartSection``: 차트 데이터가 비어 있으면 TimeLineEmptyState 노출, 있으면 최대 3개 카드 렌더
    - 헤더 문장 품질을 위해 normalizeTrailingDots(_:)로 말미의 ...를 .로 정리합니다.

> Tip:
>
> Dashboard 확장 시에도 아래 원칙을 유지하세요.
> 1. View는 이벤트를 Action으로 변환해 Store로 전달
> 2. 데이터 조회/가공/분석/조건 분기는 DashboardFeature에서 수행
> 3. 렌더링은 State 변화의 결과로만 발생

---

## 5. 상태 다이어그램 (State Diagram)

DashboardFeature.swift / DashboardView.swift의 상태 변수 정의와 화면 전이(State Transition) 명세입니다.

### 5.1 상태 변수 정의 (State Variables)

| Variable Name | Description | Available Interactions |
| :--- | :--- | :--- |
| tab | 현재 선택 탭 (visitDuration / visitFrequency) | • Segmented Picker로 전환 |
| caseID | 분석 대상 케이스 ID | • 화면 진입 시 설정 |
| hasLoaded | 초기 데이터 세팅 완료 여부 | • 중복 로드 방지 |
| locations | CoreData에서 로드한 원본 위치 데이터 | • 랭킹/분석/AI 분석 데이터로의 입력 |
| topVisitDurationLocations | 체류시간 Top3 랭킹 데이터 | • 카드 탭 -> 상세 이동 시 정보 전달용 |
| topVisitFrequencyLocations | 방문빈도 Top3 랭킹 데이터 | • 카드 탭 -> 상세 이동 시 정보 전달용 |
| cellCharts | 시간대별 방문 패턴 차트 데이터 | • 요일 Pill Picker 변경 (selectedWeekday) |
| visitDurationSummary | 체류시간 탭 헤더 요약 문장(3줄) | • 헤더 표시용 |
| visitFrequencySummary | 방문빈도 탭 헤더 요약 문장(3줄) | • 헤더 표시용 |
| isAnalyzingWithFM | Foundation Model 분석 진행 여부 | • 진행중 문장 노출 |

> Note:
> - 로딩 UI는 별도 표시하지 않음: “로딩 상태”는 헤더 문장으로만 표현됩니다.  
> - 탭별 summary가 비어 있을 때만 분석을 재요청하여 중복 스트리밍을 방지합니다.  

### 5.2 상태 다이어그램 (Visual Diagram)

![분석 탭 상태 다이어그램](dashboard-state-diagram.svg)

### 5.3 주요 전이 상세 (Transition Details)
- **진입 → 초기 로드**
    - **Action**: DashboardFeature/Action/onAppear(UUID)
    - **Effect**: caseID 설정, repository fetch → .setInitialData
- **초기 데이터 세팅 완료 → 분석 트리거**
    - **Action**: DashboardFeature/Action/setInitialData(...)
    - **Effect**: locations/top/chart 반영, summary 초기화 → locations가 비어있지 않으면 .analyzeWithFoundationModel
- **탭 전환 → 필요 시 분석**
    - **Action**: DashboardFeature/Action/setTab(DashboardPickerTab)
    - **Effect**: hasLoaded == true && locations 존재 && 해당 탭 summary가 비어있으면 .analyzeWithFoundationModel
- **스트리밍 partial 수신**
    - **Action**: DashboardFeature/Action/updatePartialAnalysis(...)
    - **Effect**: 헤더 문장 실시간 갱신
- **스트리밍 종료/실패**
    - **Action**: setAnalysisResult / analysisFailed
    - **Effect**: isAnalyzingWithFM = false, 최종 문장 확정 또는 실패 처리

---

## 6. 의존성 다이어그램 (Dependency Diagram)

![의존성 탭 의존성 다이어그램](dashboard-dependency-diagram.svg)


## 7. 파일 구조

```
Sources/
├── 📁 Data/
│    └── 🗂️ Repository/
│         └── LocationRepository.swift
├── 📁 Presentation/
│    └── 🗂️ DashboardScene/
│         ├── 🗂️ Models/
│         │    ├── CellChartData.swift
│         │    ├── HourlyVisit.swift
│         │    ├── StayAddress.swift
│         │    └── Weekday.swift
│         ├── 🗂️ SubViews/
│         │    ├── 🗂️ Sections/
│         │    │    ├── DashboardChartSection.swift
│         │    │    ├── DashboardHeader.swift
│         │    │    └── DashboardRankSection.swift
│         │    ├── CellChartCard.swift
│         │    ├── CellChartGraph.swift
│         │    ├── CellChartLegend.swift
│         │    ├── CellChartTitle.swift
│         │    ├── DashboardSectionHeader.swift
│         │    └── WeekdayPillPicker.swift
│         ├── DashboardFeature.swift
│         ├── DashboardPickerTab.swift
│         └── DashboardView.swift
└── 📁 Util/
     └── 🗂️ FoundationModels/
          ├── 🗂️ Generable/
          │    ├── VisitDurationSummary.swift
          │    └── VisitFrequencySummary.swift
          └── DashboardAnalysisService.swift
```

---

## 8. 예외 상황 및 대응 기준

### 예외 상황 1: 위치 데이터 로드 실패
- **증상**: 랭킹/차트에 데이터가 표시되지 않고 EmptyState가 노출됨
- **원인**: LocationRepository.fetchLocations(caseId:)에서 CoreData fetch 실패(throw)
- **대응**: DashboardFeature.onAppear catch에서 .none 반환 → 초기값 유지  
  → UI는 섹션 내부에서 TimeLineEmptyState(message: .bottomSheetNoCellData)로 폴백

### 예외 상황 2: 위치 데이터가 없음
- **증상**: Top3 및 차트가 비어 있고 EmptyState만 표시됨
- **원인**: 해당 Case에 연결된 Suspect/Location 관계가 비어 있음  
  (LocationRepository에서 Case 또는 Suspect/Location이 없으면 [] 반환)
- **대응**: DashboardFeature.setInitialData에서 locations.isEmpty면 분석 미수행, UI는 EmptyState 노출

### 예외 상황 3: AI 분석 실패
- **증상**: 헤더가 “분석중…”에서 갱신되지 않거나, 탭에 따라 “데이터가 충분하지 않아요.” 상태로 보임
- **원인**: Foundation Model 스트리밍 생성 실패/iteration 에러/partial 미수신
- **대응**: analysisFailed로 전환하여 isAnalyzingWithFM = false

---

## 9. 기능 한계 및 주의사항

- **에러 원인 안내 부족**: 로드/분석 실패의 원인을 사용자에게 구체적으로 전달하지 않고, EmptyState 또는 문장 폴백으로 처리됩니다.
- **분석 근거의 단순화**
  - 체류시간 분석은 topDuration 1위 주소의 receivedAt.hour 분포에서 최빈값 1시간 구간을 사용합니다.
  - 방문빈도 분석은 topFrequency 1위 주소의 startOfDay 그룹에서 최빈 날짜/요일을 사용합니다.
- **주소 매칭 방식 주의** : 분석 입력 필터링에서 location.address.isEmpty ? "기지국 주소" : location.address 방식으로 주소를 비교합니다. (주소 누락 데이터가 혼재하면 결과가 달라질 수 있음)

---

## 10. 향후 개선 사항

### 기능 고도화
- “Top1” 외에도 Top2/Top3에 대한 보조 인사이트(예: 차이, 분산, 요일 패턴)를 함께 제공 -> 현재 Foundation Model 활용시
- 분석 결과에 근거 수치(예: 최빈 시간대 방문 수, 최빈 날짜 방문 수)를 UI에 같이 노출
- **에러 처리에 대한 고도화 필요**: 실패 시 재시도 버튼/토스트 등 사용자 피드백 추가

### 기술 부채
- DashboardFeature.onAppear에서 실패 시 .none으로 종료되어 “실패 상태”가 남지 않음 → loadFailed(Error) 같은 상태/액션 도입 고려
- CoreData 관계 가정 (케이스당 suspect 1명 등)이 바뀔 경우 조회/연결 로직 영향 범위가 큼 -> 즉, 추후 Case당 suspect가 2명 이상으로 확장되는 경우 연쇄적인 수정 사항이 많아질 것이 우려됨.

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| --- | --- |
| 담당자 | 이민재 (iOS Developer) |
| 관련 문서 | (관련 문서 링크) |

---

## Topics

### Core Components

- ``DashboardView``
- ``DashboardFeature``
- ``LocationRepository``
- ``DashboardAnalysisService``

### UI Components
대시보드 탭에서 하위 뷰로 갖고 있는 녀석들입니다.

- ``DashboardHeader``
- ``DashboardRankSection``
- ``DashboardChartSection``
- ``CellChartCard``
- ``CellChartGraph``
- ``WeekdayPillPicker``
- ``TimeLineEmptyState`

### Data Models
대시보드 탭에서 채택하고 있는 모델 객체입니다.

- ``Location``
- ``StayAddress``
- ``CellChartData``
- ``HourlyVisit``
- ``Weekday``
- ``VisitDurationSummary``
- ``VisitFrequencySummary``
