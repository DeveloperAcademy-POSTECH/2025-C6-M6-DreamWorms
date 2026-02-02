# 핀 작성 기능 (Pin Write Feature)
[기능에 대한 한 줄 설명]

지도에서 위치를 선택하여 핀(거주지/범행지/기타)을 추가하고 관리하는 기능

> 📅 **작성일**: 2026.01.27  
> 👤 **작성자**: Taeni  
> 🏷️ **버전**: v1.0

---

## 1. 기능 개요

### 기능명

핀 추가/수정 (PinWriteFeature)

### 기능 정의

지도에서 특정 위치를 탭하여 수사 관련 장소 정보를 핀으로 등록하고 관리한다.
핀에는 이름, 색상, 카테고리(거주지/범행지/기타)를 지정할 수 있으며, 형사 노트를 추가하여 수사 메모를 기록할 수 있다.

핵심 아키텍처:
- ``PinWriteFeature``: 핀 추가/수정 UI 상태 관리 및 저장 로직
- ``NoteWriteFeature``: 형사 노트 작성/수정 관리
- ``MapFeature``: 상위 Feature, 핀 저장 완료 시 지도 상태 업데이트
- ``LocationRepository``: CoreData 기반 Location 저장/수정/삭제

주요 기능:
- 핀 추가: 지도에서 위치 탭 → 핀 이름/색상/카테고리 지정 → 저장
- 핀 수정: 기존 핀 탭 → 정보 수정 → 저장
- 핀 삭제: 기존 핀 탭 → 삭제 확인 → 삭제
- 형사 노트: 핀에 수사 메모 추가/수정/삭제

### 도입 목적

- **장소 기록**: 수사 중 중요 장소(거주지, 범행지, 기타)를 지도에 표시하여 시각화
- **카테고리 분류**: 장소 유형별 분류로 수사 정보 체계적 관리
- **색상 구분**: 7가지 색상으로 핀 간 시각적 구분
- **메모 기록**: 형사 노트로 장소별 수사 내용 기록

---

## 2. 기능 적용 범위

1. 수동 핀 추가 : MainTab > MapScene > PlaceInfoSheet > PinWriteView
2. 문서 스캔 핀 추가 : CameraScene > ScanLoadScene > ScanListScene


### 사용자 인터랙션

| 인터랙션 | 동작 | 결과 |
| :--- | :--- | :--- |
| 지도 위치 탭 | ``PlaceInfoSheet`` 표시 | Kakao API로 주소 정보 조회 |
| 핀 추가 버튼 탭 | ``PinWriteView``로 전환 | 핀 이름/색상/카테고리 입력 화면 |
| 핀 이름 입력 | 텍스트 입력 | 1~20자, 이모지 불가 |
| 색상 선택 | 7가지 색상 중 선택 | 선택된 색상 강조 표시 |
| 카테고리 선택 | 거주지/범행지/기타 중 선택 | 선택된 카테고리 강조 |
| 저장 버튼 탭 | CoreData에 Location 저장 | 지도에 핀 마커 추가 |
| 기존 핀 탭 | ``PlaceInfoSheet`` 표시 | 핀 정보 및 형사 노트 표시 |
| 핀 수정 버튼 탭 | ``PinWriteView``로 전환 (수정 모드) | 기존 데이터 로드 |
| 핀 삭제 버튼 탭 | 삭제 확인 Alert | 확인 시 CoreData에서 삭제 |
| 형사 노트 버튼 탭 | ``NoteWriteView``로 전환 | 메모 입력/수정 화면 |

---

## 3. 화면 흐름도 (Screen Flow)

![PinWrite 화면 흐름도](../../Resources/PinWrite/pin-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

![PinWrite Sequence](../../Resources/PinWrite/pin-sequence.svg)

### 4.2 흐름 설명

**1. 위치 선택 및 정보 조회**
- 사용자가 지도에서 위치를 탭하면 `.mapTapped(latlng:)` 액션 발생
- ``MapFeature``가 Kakao Geocode API로 주소 정보 조회
- ``PlaceInfoSheet``에 주소 정보 표시, 기존 핀 여부 확인

**2. 핀 추가 (Add Mode)**
- `.addPinTapped` 액션 발생 시 `isPinWritePresented = true`
- ``PinWriteView`` 표시, `existingLocation = nil`로 추가 모드 진입
- 사용자가 핀 이름/색상/카테고리 선택 후 `.saveTapped`
- ``LocationRepository.createLocations()``로 CoreData에 저장
- `.saveCompleted(location)` → 상위 ``MapFeature``에 콜백

**3. 핀 수정 (Edit Mode)**
- `.editPinTapped` 액션 발생 시 `isEditMode = true`
- ``PinWriteView`` 표시, `existingLocation`에서 기존 데이터 로드
- `.onAppear`에서 `pinName`, `selectedColor`, `selectedCategory` 설정
- 수정 후 `.saveTapped` → ``LocationRepository.updateLocation()``

**4. 핀 삭제**
- `.confirmDeletePin` 액션 발생
- ``LocationRepository.deleteLocation(id:)`` 호출
- `.deletePinCompleted` → 지도에서 마커 제거

**5. 형사 노트**
- `.noteButtonTapped` → ``NoteWriteView`` 표시
- 노트 입력/수정 후 `.saveTapped` → ``LocationRepository.updateLocation()``
- `.noteSaveCompleted(note)` → ``MapFeature`` 상태 업데이트

---

## 5. 상태 다이어그램 (State Diagram)

### PinWriteFeature 상태

![PinWrite Sequence](../../Resources/PinWrite/pin-wirte-state.svg)

### NoteWriteFeature 상태

![PinWrite Sequence](../../Resources/PinWrite/pin-note-state.svg)

---

## 6. 의존성 다이어그램 (Dependency Diagram)

![PinWrite Sequence](../../Resources/PinWrite/pin-dependency.svg)
---

## 서비스 레이어 역할

- **LocationRepository** (`class`)
  - CoreData 기반 Location CRUD
  - `createLocations(data:caseId:)`: 핀 생성
  - `updateLocation(_:)`: 핀 수정
  - `deleteLocation(id:)`: 핀 삭제
  - `fetchLocations(caseId:)`: 케이스별 핀 조회

- **KakaoGeocodeAPI** (`service`)
  - 좌표 → 주소 변환 (Reverse Geocoding)
  - `PlaceInfo` 반환 (지번주소, 도로명주소, 전화번호)

---

## PinWriteFeature.State

| 변수명 | 타입 | 설명 |
| :--- | :--- | :--- |
| `caseId` | `UUID` | 현재 케이스 ID |
| `placeInfo` | `PlaceInfo` | 장소 정보 (주소 등) |
| `coordinate` | `MapCoordinate?` | 지도 좌표 |
| `existingLocation` | `Location?` | 기존 Location (수정 모드) |
| `isEditMode` | `Bool` (computed) | 수정 모드 여부 (`existingLocation != nil`) |
| `pinName` | `String` | 핀 이름 입력값 |
| `selectedColor` | `PinColorType` | 선택된 색상 (기본값: `.black`) |
| `selectedCategory` | `PinCategoryType` | 선택된 카테고리 (기본값: `.home`) |
| `isPinNameFocused` | `Bool` | 핀 이름 입력 필드 포커스 여부 |
| `isValidPinName` | `Bool` (computed) | 핀 이름 유효성 (1~20자, 이모지 불가) |

---

## NoteWriteFeature.State

| 변수명 | 타입 | 설명 |
| :--- | :--- | :--- |
| `existingNote` | `String?` | 기존 노트 내용 |
| `existingLocation` | `Location` | 기존 Location 정보 |
| `noteText` | `String` | 노트 텍스트 입력값 |
| `isTextEditorFocused` | `Bool` | 텍스트 에디터 포커스 여부 |
| `showDeleteConfirmation` | `Bool` | 삭제 확인 Alert 표시 여부 |
| `hasNote` | `Bool` (computed) | 노트 내용 존재 여부 |

---

## Action 명세

### PinWriteFeature.Action

| Action | 설명 | 트리거 |
| :--- | :--- | :--- |
| `onAppear` | 화면 진입 시 기존 데이터 로드 | `.task` |
| `updatePinName(String)` | 핀 이름 입력 | TextField onChange |
| `selectColor(PinColorType)` | 색상 선택 | 색상 버튼 탭 |
| `selectCategory(PinCategoryType)` | 카테고리 선택 | 카테고리 카드 탭 |
| `saveTapped` | 저장 버튼 탭 | 저장 버튼 |
| `saveCompleted(Location)` | 저장 완료 | 내부 (Repository 성공) |
| `cancelTapped` | 취소 버튼 탭 | 닫기 버튼 |

### NoteWriteFeature.Action

| Action | 설명 | 트리거 |
| :--- | :--- | :--- |
| `onAppear` | 화면 진입 시 기존 노트 로드 | `.task` |
| `focusCompleted` | 포커스 설정 완료 | 내부 (딜레이 후) |
| `updateNoteText(String)` | 노트 텍스트 입력 | TextEditor onChange |
| `saveTapped` | 저장 버튼 탭 | 저장 버튼 |
| `deleteTapped` | 삭제 버튼 탭 | 삭제 버튼 |
| `confirmDelete` | 삭제 확인 | Alert 확인 버튼 |
| `dismissDeleteAlert` | 삭제 Alert 닫기 | Alert 취소 버튼 |
| `saveCompleted(Location)` | 저장 완료 | 내부 |
| `cancelTapped` | 취소 버튼 탭 | 닫기 버튼 |

### MapFeature Pin Actions

| Action | 설명 |
| :--- | :--- |
| `addPinTapped` | 핀 추가 버튼 탭 |
| `editPinTapped` | 핀 수정 버튼 탭 |
| `confirmDeletePin` | 핀 삭제 확인 |
| `deletePinCompleted` | 핀 삭제 완료 |
| `pinSaveCompleted(Location)` | 핀 저장 완료 (PinWriteFeature 콜백) |
| `closePinWrite` | 핀 작성 화면 닫기 |
| `noteButtonTapped` | 형사 노트 버튼 탭 |
| `noteSaveCompleted(String?)` | 노트 저장 완료 (NoteWriteFeature 콜백) |
| `closeNoteWrite` | 노트 작성 화면 닫기 |

---

## Enum 명세

### PinColorType

| Case | rawValue | 색상 |
| :--- | :---: | :--- |
| `black` | 0 | 검정 (기본값) |
| `red` | 1 | 빨강 |
| `orange` | 2 | 주황 |
| `yellow` | 3 | 노랑 |
| `lightGreen` | 4 | 연두 |
| `darkGreen` | 5 | 초록 |
| `purple` | 6 | 보라 |

### PinCategoryType

| Case | rawValue | 텍스트 | 설명 |
| :--- | :---: | :--- | :--- |
| `home` | 0 | 거주지 | 주민등록주소/실거주지/은신처 등 생활거점 |
| `work` | 1 | 범행지 | 전과기록/증거물/수사보고서 등 주요 범행기록 |
| `custom` | 3 | 기타 | 직장/단골가게/전화발신주소 등 주요 활동기록 |

---

## 7. 파일 구조

```
Sources/
├── 📁 Presentation/
│    ├── 🗂️ MapScene/
│    │    ├── 🗂️ SubView/
│    │    │    ├── MapSheetPanel.swift            // 바텀시트 패널 
│    │    │    └── PlaceInfoSheet.swift           // 장소 정보 시트
│    │    ├── MapFeature.swift                    
│    │    └── MapView.swift                       // 지도 메인 화면
│    ├── 🗂️ MapPinWriteScene/
│    │    ├── 🗂️ Note/
│    │    │    ├── 🗂️ SubView/
│    │    │    │    └── NoteWriteHeader.swift     // 노트 작성 헤더
│    │    │    ├── NoteWriteFeature.swift         
│    │    │    └── NoteWriteView.swift            // 형사 노트 화면
│    │    └── 🗂️ Pin/
│    │         ├── 🗂️ Extension/
│    │         │    └── String+Validation.swift   // 문자열 유효성 검사 Extension
│    │         ├── 🗂️ SubViews/
│    │         │    └── PinWriteHeader.swift      // 핀 작성 헤더
│    │         ├── PinWriteFeature.swift         
│    │         └── PinWriteView.swift             // 핀 추가/수정 화면
│    └── 🗂️ ScanListScene/
│         └── 🗂️ Enum/
│              └── PinCategoryType.swift          // 핀 카테고리 타입 (거주지/범행지/기타)
├── 📁 Data/
     ├── 🗂️ Enum/
     │    ├── LocationType.swift                  // 위치 타입 (home/work/cell/custom)
     │    └── PinColorType.swift                  // 핀 색상 타입
     └── 🗂️ Repository/
          └── LocationRepository.swift            // Location CRUD
```

---

## 8. 예외 상황 및 대응 기준

### 예외 상황 1: 핀 이름 유효성 검사 실패

- **증상**: 저장 버튼 비활성화
- **원인**: 빈 문자열, 20자 초과, 이모지 포함
- **대응**: `isValidPinName` computed property로 실시간 검증, 이모지 자동 제거

### 예외 상황 2: 좌표 없음

- **증상**: 저장 진행 안 됨
- **원인**: `coordinate`와 `existingLocation` 모두 nil
- **대응**: `.saveTapped`에서 `guard let coordinateSource` 검사 후 `.none` 반환

### 예외 상황 3: 저장 실패

- **증상**: 저장 후 지도에 핀 미표시
- **원인**: CoreData 저장 오류
- **대응**: 현재 `return nil`로 처리 (향후 에러 Alert 추가 필요)

---

## 9. 기능 한계 및 주의사항

### 기술적 제한사항

| 항목 | 제한 | 이유 |
| :--- | :--- | :--- |
| 핀 이름 | 1~20자 | UI 표시 공간 제약 |
| 이모지 | 불가 | 렌더링 일관성 |
| 색상 | 7가지 고정 | 디자인 시스템 |
| 카테고리 | 3가지 고정 | 수사 업무 요구사항 |

### 주의사항

- PinWriteFeature는 `onSaveCompleted` 콜백으로 상위 Feature에 저장 완료 알림
- MapFeature에서 `updateLocationInState()`로 State 동기화 필수
- 수정 모드에서 기존 `note` 유지 필요 (`existingLocation?.note` 참조)

---

## 10. 향후 개선 사항

### 기능 고도화

- 저장 실패 시 에러 Alert 표시
- 핀 이름 중복 검사
- 핀 색상 커스텀 추가
- 핀 아이콘 커스텀 지원

### 기술 부채

- PinWriteFeature 저장 실패 시 에러 처리 미흡 (`return nil`)
- NoteWriteFeature와 PinWriteFeature 간 중복 코드 존재

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| :--- | :--- |
| 담당자 | Taeni |
| 관련 문서 | MapFeature.md, ScanListFeature.md |

---

## Topics

### Core Components

- ``PinWriteFeature``
- ``PinWriteView``
- ``NoteWriteFeature``
- ``NoteWriteView``

### Parent Feature

- ``MapFeature``
- ``MapSheetPanel``
- ``PlaceInfoSheet``

### Data Types

- ``PinColorType``
- ``PinCategoryType``
- ``LocationType``
- ``Location``
- ``PlaceInfo``

### Repository

- ``LocationRepository``
- ``LocationRepositoryProtocol``
