# 사건 관리 기능 (Case Feature)
사건(Case)을 생성/수정/삭제하고,   
사건 리스트에서 특정 사건으로 진입하거나(메인 탭), 쇼케이스용 목데이터(기지국/핀)를 주입하는 기능입니다.

> 📅 **작성일**: 2026.02.01    
> 👤 **작성자**: 이민재 (Mini)  
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명

- **Case Feature (사건 관련 관리 기능)**

### 기능 정의

Case Feature는 다음 두 화면을 중심으로 동작합니다.
- ``CaseListView``: 저장된 사건 목록을 조회하고, 사건 선택/삭제/편집/목데이터 주입 메뉴를 제공합니다.
- ``CaseAddView`` + ``CaseAddFeature``: 사건 생성/수정 폼(UI)과 비즈니스 로직을 담당합니다.

데이터는 ``CaseRepository``가 CoreData(``CaseEntity``, ``SuspectEntity``)를 통해 영속화하며,  
사건 생성 시 ``Suspect``를 1명 생성하여 ``Case``에 연결합니다.

### 도입 목적
- "사건 단위"로 수사 데이터를 묶어 관리하기 위함입니다.
- “사건 생성 → 메인 탭 진입 → 지도/타임라인 등 분석 기능 사용”의 진입점을 제공하기 위함입니다.
- (SHOWCASE 25 한정) 쇼케이스/테스트를 위한 목데이터 주입 UX(기지국/핀)를 제공하기 위함입니다.

---

## 2. 기능 적용 범위

### 사용 위치

1. 앱 진입 후 사건 리스트 화면: ``CaseListView``
2. 사건 생성/편집 화면: ``CaseAddView``

### 사용자 관점 동작 조건

1. 사용자가 사건 리스트 화면에 진입하면 ``CaseListFeature``가 CaseRepositoryProtocol.fetchCases()로 사건 목록을 로드합니다.
2. 사용자가 추가 버튼을 누르면 사건 추가 화면으로 이동합니다. (coordinator.push(.caseAddScene()))
3. 사용자가 편집 버튼을 누르면 사건 추가 화면이 편집 모드로 진입합니다. (coordinator.push(.caseAddScene(caseID: item.id)))
4. 사건 추가/편집 완료 시 저장 로직이 실행되고, 화면이 pop 됩니다. (store.send(.addCaseButtonTapped) + coordinator.pop())

---

## 3. 화면 흐름도 (Screen Flow)

![사건 화면 흐름도](case-screen-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

- 사건 리스트 로드 + 삭제

![사건 화면 의존성 다이어그램](case-sequence-diagram-1.svg)

- 사건 추가 + 편집 저장

![사건 화면 의존성 다이어그램](case-sequence-diagram-2.svg)

### 4.2 흐름 설명

1) 사건 리스트 로딩
- CaseListView가 .task { store.send(.onAppear) }로 시작합니다.
- CaseListFeature.Action.onAppear → repository.fetchCases() 호출 → .loadCases([Case])로 State 업데이트합니다.
- View는 store.state.cases를 기반으로 카드 리스트를 렌더링합니다.

2) 사건 생성 (신규)
- CaseAddView에서 사용자가 폼을 채우고 버튼 탭:
    - “다음(Next)” 버튼이 단계적으로 필드를 노출합니다. (CaseAddScrollForm의 visibleCount 기반)
    - 마지막 필드(전화번호)까지 채워져 state.isFormComplete == true가 되면 “추가하기”로 전환됩니다.
- CaseAddFeature.Action.addCaseButtonTapped 발생 시
    - editingCaseId == nil → repository.createCase(model:imageData:phoneNumber:) 실행

3) 사건 편집
- CaseAddFeature.Action.onAppear에서 editingCaseId가 있으면
    repository.fetchCaseForEdit(for:) 호출 후 -> .setExistingCase(caseModel, phoneNumber, profileImagePath)로 폼을 채웁니다.
- 이미지 처리
    - 편집 모드에서 기존 이미지는 existingProfileImagePath로 유지합니다.
    - 사용자가 새 이미지를 고르면 FullScreenPhotoPicker → .setProfileImage(Data?)로 Data만 업데이트합니다.
- 저장 시
    - repository.updateCase(model:imageData:phoneNumber:)에서
    - imageData == nil이면 기존 이미지 유지 / imageData != nil이면 기존 파일 삭제 후 새 파일 저장, CoreData에는 “경로”만 저장합니다.

4) 사건 삭제
- CaseListFeature.Action.deleteTapped(item:)에서 repository.deleteCase(id:) 실행
- 삭제 완료 후 fetchCases()를 재호출해서 리스트를 갱신합니다.
- deleteCase 내부에서 Suspect의 기존 이미지 파일도 함께 삭제합니다. (ImageFileStorage.deleteProfileImage(at:))

5) 쇼케이스용 목데이터(기지국/핀) 추가
- CaseCard의 Menu에서 “기지국 추가 / 핀 추가” 선택 시 ``CaseListFeature``에서 CoreData context를 직접 가져와 ``LocationRepository``를 생성합니다.
- 기존 데이터 존재 여부를 체크하고, 있으면 Overwrite Alert를 띄웁니다.
- overwrite가 true면 기존 데이터를 삭제한 뒤 새 샘플 데이터를 생성/저장합니다.

---

## 5. 상태 다이어그램 (State Diagram)

### 5.1 상태 변수 정의 (State Variables)

1) CaseListFeature.State  

| Variable Name | Description | 
| :--- | :--- |
| selectedTab | 탭 선택 상태 (현재는 .allCase만 유효) |
| cases | 렌더링할 사건 목록 | 
| targetCaseIdForCellLog | 기지국 목데이터 대상 케이스 |
| isShowingOverwriteAlert / isShowingSuccessAlert | 기지국 overwrite/완료 Alert 제어 |
| targetCaseIdForPinData | 핀 목데이터 대상 케이스 |
| isShowingPinDataOverwriteAlert / isShowingPinDataSuccessAlert | 핀 overwrite/완료 Alert 제어 |

2. CaseAddFeature.State

| Variable Name | Description | 
| :--- | :--- |
| editingCaseId | nil이면 신규, 값이 있으면 편집 모드 | 
| caseName, caseNumber, suspectName, crime, suspectPhoneNumber | 폼 입력값 |
| suspectProfileImage | 사용자가 새로 선택한 이미지 Data | 
| existingProfileImagePath | 편집 모드에서 기존 이미지 경로 |
| isFormComplete | 5개 필드가 모두 채워졌는지 |

### 5.2 상태 다이어그램 (Visual Diagram)

![사건 화면 의존성 다이어그램](case-state-diagram-1.svg)

![사건 화면 의존성 다이어그램](case-state-diagram-2.svg)

### 5.3 주요 전이 상세 (Transition Details)

- CaseList onAppear → .loadCases
- CaseAdd onAppear(편집) → .setExistingCase
- addCaseButtonTapped → create/update task 실행
- deleteTapped → delete → reload
- cellLogMenuTapped/pinDataMenuTapped → existing check → overwrite alert 또는 바로 추가 → success alert


---

## 6. 의존성 다이어그램 (Dependency Diagram)

![사건 화면 의존성 다이어그램](case-dependency-diagram.svg)

---

## 7. 파일 구조

```
Sources/
├── 📁 Data/
│    ├── 🗂️ Repository/
│    │    └── CaseRepository.swift  
│    ├── ImageFileStorage.swift
│    └── Persistence.swift
└── 📁 Presentation/
     ├── 🗂️ CaseAddScene/
     │    ├── 🗂️ SubViews/
     │    │    ├── CaseAddScrollForm.swift  
     │    │    ├── FullScreenPhotoPicker.swift  
     │    │    └── SuspectImageSelector.swift  
     │    ├── CaseAddFeature.swift            
     │    └── CaseAddView.swift             
     └── 🗂️ CaseListScene/
          ├── 🗂️ Model/
          │    └── Case.swift  
          ├── 🗂️ SubViews/
          │    ├── CaseCard.swift  
          │    ├── CaseListBottomFade.swift  
          │    ├── CaseListEmpty.swift  
          │    └── CaseListHeader.swift  
          ├── CaseListFeature.swift            
          └── CaseListView.swift        
```

---

## 8. 예외 상황 및 대응 기준

> Warning:
> 현재 사건 관련 화면에서는 별도의 에러 처리가 이루어지지 않고 있습니다.  
> 현재 Repository로부터 데이터 저장, 로딩을 할 수 없거나 / 이미지가 갱신되지 않는 경우 별도의 UX 노출 없이 .none 처리가 이루어집니다.

---

## 9. 기능 한계 및 주의사항

- **CoreData 관계 가정**: CaseEntity ↔ SuspectEntity가 “케이스당 1명의 주요 용의자”를 전제로 작성돼 있습니다.  
fetchCases(), fetchAllDataOfSpecificCase(), fetchCaseForEdit(), updateCase() 등에서 suspects.first를 primary suspect로 사용합니다.  
추후, 케이스당 용의자의 수가 2명 이상으로 늘어나는 패치 시 관련 로직을 수정해야합니다.
- **목데이터 주입 책임 위치**: CaseListFeature에서 직접 CoreData context를 가져와 LocationRepository를 생성합니다. (추후 DI/Repository 추상화로 정리 여지)

---

## 10. 향후 개선 사항

### 기능 고도화

- 사건 한개당 용의자 2명 이상 등록 가능하도록 추후 기능 확장 필요
- 현재 사건 등록시 Shortcuts 전화번호 등록하도록 하는 방식 -> 더 나은 방식으로 개선 필요
- 실패 케이스 UX: .none로 삼키는 실패를 사용자에게 안내할 수 있는 에러 State/Alert/Toast 도입 필요

### 기술 부채

- “케이스당 suspect 1명” 가정이 깨지는 경우 영향 범위가 큽니다.  
suspects.first 기반 로직(조회/수정/삭제/렌더링)을 PrimarySuspect 개념 도입 또는 관계 모델링 변경으로 분리할 필요가 있습니다.

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| --- | --- |
| 담당자 | 이민재 (iOS Developer) |
| 관련 문서 | (관련 문서 링크) |

---
