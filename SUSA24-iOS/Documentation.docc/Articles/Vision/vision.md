# 스캔 기능 (Vision Feature)

문서 이미지 분석 및 한국 주소 자동 추출 기능

> 📅 **작성일**: 2026.01.24  
> 👤 **작성자**: Taeni  
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명

문서 스캔 및 주소 추출

### 기능 정의

Vision Framework 의 RecognizeDocumentsRequest를 주로 활용하여 문서 이미지에서 테이블, 리스트, 텍스트를 분석한다.
``VisionModel`` 에서 관리되는 State에 문서 이미지를 분석하고 주소를 추출하는 기능이 포함되어 있다.


Vision Framework를 활용하여 문서 스캔 기능을 제공한다.
1. 카메라 사용 시 실시간 문서 감지 및 렌즈 얼룩 감지
2. 문서 이미지를 분석하여 한국 주소 추출 및 API를 이용한 검증 

핵심 아키텍쳐
- ``ScanLoadFeature``: 분석 진행 상태 관리
- ``ScanListFeature``: 결과 목록 및 저장 관리
- ``BatchAddressAnalyzer``: 다중 이미지 순차 분석
- ``DocumentAnalyzer``: Vision Framework 기반 문서 구조 분석
- ``AddressExtractor``: 테이블/텍스트에서 주소 추출
- ``KoreanAddressPattern``: 한국 주소 정규식 매칭

주요 기능
- 실시간 감지: 카메라 프리뷰에서 문서 경계 및 렌즈 얼룩 감지 (3fps)
- 문서 구조 분석: 테이블 → 리스트 → 텍스트 우선순위로 주소 추출
- 좌표 검증: Naver Geocode API로 주소 유효성 검증 및 좌표 변환
- 중복 감지: 동일 주소 출현 빈도 카운팅


### 도입 목적

- 실시간 감지: 촬영 전 문서 경계를 시각적으로 확인하여 촬영 품질 향상
- 렌즈 얼룩 감지: 렌즈 오염 시 토스트로 안내하여 선명한 이미지 확보
- 주소 자동 추출: 수사관이 다량의 문서에서 주소 정보를 수동으로 입력하는 번거로움 해소
- 좌표 검증: 문서 이미지에서 주소를 자동 인식하여 정확한 좌표로 변환
- 중복 감지: 중복 주소 감지를 통해 방문 빈도 파악 시 핀 추가 지원

---

## 2. 기능 적용 범위

### 사용 위치

1. MainTab > MapScene > CameraScene > ScanLoadScene
2. 문서 촬영 후 분석 화면

### 사용자 관점 동작 조건

1. 사용자가 **[카메라 스캔 버튼을 탭]**하면 [``ScanLoadView``]로 [이동]한다.
2. [``ScanLoadView``]가 [``CameraSession``] 을 이용해 실시간으로 [분석]한다.
3. 분석 중 로딩 애니메이션을 표시한다.
4. 분석 완료 후 [``ScanListView``] 로 이동하여 추출된 주소 목록을 표시한다.
5. 사용자가 주소 목록 중 추가할 리스트를 선택하고 카테고리를 지정하여 핀을 추가한다.

| 인터랙션 | 동작 | 결과 |
|----------|------|------|
| 스캔 버튼 탭 | [``ScanLoadView``]로 이동 | Vision 분석 자동 시작 |
| 분석 완료 대기 | 로딩 애니메이션 표시 | 진행률 업데이트 |
| 분석 완료 | [``ScanListView``]로 자동 이동 | 추출된 주소 목록 표시 |
| 주소 체크박스 탭 | 선택 / 해제 토글 | 선택된 주소 강조 |
| 카테고리 선택 | 핀 카테고리 지정 | 거주지 / 직장 / 기타 선택 |
| 핀 추가 버튼 탭 | 중복 확인 후 저장 | CoreData에 Location 저장 |
| 분석 실패 시 | 재시도 Alert 표시 | 재촬영 또는 취소 선택 |

---

## 3. 화면 흐름도 (Screen Flow)

![Vision 흐름도](vision-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

### 4.2 흐름 설명

1. Vision 분석 단계
[``ScanLoadView``] 진입 시 .startScanning(photos) 액션 자동 발생
``BatchAddressAnalyzer/analyzePhotos(_:progressHandler:)``가 각 사진을 순차적으로 분석
``DocumentAnalyzer/analyzeDocument(from:)``가 ``RecognizeDocumentsRequest``로 테이블/리스트/텍스트 추출
추출 우선순위: 테이블 → 리스트 → 텍스트 (Fallback)

2. 주소 추출 단계
``AddressExtractor/extractAddressColumnFromTable(_:)``이 테이블에서 "주소" 컬럼 탐색
헤더 탐색 실패 시 테이블 행열 전치 후 재시도
최종 실패 시 fallbackScan()으로 전체 셀 스캔
``KoreanAddressPattern``이 도로명/지번 주소 정규식 매칭

3. 좌표 검증 단계
.visionAnalysisCompleted 후 validateAddressesWithGeocode() 호출
TaskGroup으로 모든 주소를 병렬 Geocode 검증
검증 성공한 주소만 ``ScanResult``로 변환

4. 저장 단계
사용자가 주소 선택 + 카테고리(거주지/직장/기타) 지정
.saveButtonTapped → .checkDuplicateLocations → .executeSave
기존 주소와 중복 시 덮어쓰기 Alert 표시

---

## 5. 상태 다이어그램 (State Diagram)

![Vision load state 다이어그램](vision-load-state.svg)

---

![Vision list state 다이어그램](vision-list-state.svg)

---

## 6. 의존성 다이어그램 (Dependency Diagram)

![Vision 의존성 다이어그램](vision-dependency.svg)

---

### ScanLoadFeature.State

| 변수명 | 타입 | 설명 |
|------|------|------|
| isScanning | Bool | 분석 중 여부 |
| currentIndex | Int | 현재 진행 중인 사진 인덱스 (1-based) |
| totalCount | Int | 전체 사진 개수 |
| currentPhotoId | UUID? | 현재 분석 중인 사진 ID |
| scanResults | [``ScanResult``] | 좌표 검증 완료된 결과 배열 |
| successCount | Int | Vision 분석 성공 개수 |
| failedCount | Int | Vision 분석 실패 개수 |
| errorMessage | String? | 에러 메시지 |
| isCompleted | Bool (computed) | 분석 완료 여부 |
| progress | Double (computed) | 진행률 (0.0 ~ 1.0) |
| progressPercentage | Int (computed) | 진행률 퍼센티지 (0 ~ 100) |

---

### ScanListFeature.State

| 변수명 | 타입 | 설명 |
|------|------|------|
| scanResults | [``ScanResult``] | Geocode 검증 완료된 결과 목록 |
| selectedIndex | Set<Int> | 선택된 인덱스 집합 |
| typeSelections | [Int: ``PinCategoryType``] | 각 항목의 카테고리 선택 상태 |
| isSaving | Bool | 저장 중 상태 |
| errorMessage | String? | 에러 메시지 |
| isSaveCompleted | Bool | 저장 완료 플래그 |
| showDuplicateAlert | Bool | 중복 Alert 표시 여부 |
| duplicateAddress | String? | 중복된 주소 (Alert용) |
| pendingLocations | [``Location``] | 저장 대기 중인 Location 배열 |
| currentCaseID | UUID? | 현재 케이스 ID |
| canAddPin | Bool (computed) | 핀 추가 가능 여부 |

---

### Action 명세

### ScanLoadFeature.Action

| Action | 설명 | 트리거 |
|------|------|------|
| startScanning(photos:) | 스캔 시작 | `.onAppear` |
| updateProgress(progress:) | 진행 상태 업데이트 | 내부 (progressHandler) |
| visionAnalysisCompleted(addresses:successCount:failedCount:) | Vision 분석 완료 | 내부 |
| geocodeValidationCompleted(scanResults:failedAddressCount:) | Geocode 검증 완료 | 내부 |
| scanningFailed(errorMessage:) | 스캔 실패 | 내부 |

---

### ScanListFeature.Action

#### Selection

| Action | 설명 |
|------|------|
| toggleSelection(index:) | 체크박스 토글 |
| selectType(index:type:) | 카테고리 선택 |

#### Duplicate

| Action | 설명 |
|------|------|
| checkDuplicateLocations(locations:caseID:) | 중복 확인 |
| duplicateFound(address:locations:caseID:) | 중복 발견 |
| noDuplicatesFound(locations:caseID:) | 중복 없음 |
| confirmOverwrite | 덮어쓰기 확인 |
| cancelOverwrite | 덮어쓰기 취소 |

#### Save

| Action | 설명 |
|------|------|
| saveButtonTapped(caseID:) | 저장 버튼 탭 |
| executeSave(locations:caseID:) | 실제 저장 실행 |
| saveCompleted | 저장 완료 |
| saveFailed(Error) | 저장 실패 |

#### Alert

| Action | 설명 |
|------|------|
| dismissErrorAlert | 에러 Alert 닫기 |
| dismissSaveCompletedAlert | 완료 Alert 닫기 |

---

## 주요 메소드 명세

### BatchAddressAnalyzer

| 메소드 | 시그니처 | 설명 |
|------|----------|------|
| analyzePhotos(_:progressHandler:) | func analyzePhotos(_ photos: [CapturedPhoto], progressHandler: ((AnalysisProgress) async -> Void)?) async -> BatchAnalysisResult | 다중 이미지 순차 분석 |

**내부 구조체**
- `AnalysisProgress`
  - currentIndex
  - totalCount
  - currentPhoto
  - percentage
- `BatchAnalysisResult`
  - addresses
  - successCount
  - failedCount
  - totalCount
  - isCompleted
  - isEmpty

---

### DocumentAnalyzer

| 메소드 | 시그니처 | 설명 |
|------|----------|------|
| analyzeDocument(from:) | static func analyzeDocument(from imageData: Data) async throws -> DocumentAnalysisResult | Vision RecognizeDocumentsRequest 기반 문서 분석 |
| extractTables(from:) | static func extractTables(from imageData: Data) async throws -> [Table] | 테이블만 추출 |
| extractText(from:) | static func extractText(from imageData: Data) async throws -> String | 텍스트만 추출 |

---

### AddressExtractor

| 메소드 | 시그니처 | 설명 |
|------|----------|------|
| extractAddressColumnFromTable(_:) | static func extractAddressColumnFromTable(_ table: Table) async -> [String] | 테이블에서 "주소" 컬럼 추출 (전치 지원) |
| extractAddressesFromText(_:) | static func extractAddressesFromText(_ text: String) async -> [String] | 텍스트에서 주소 추출 |
| normalizeAddresses(_:) | static func normalizeAddresses(_ addresses: [String]) -> [String] | 주소 정규화 + 중복 제거 |

---

### KoreanAddressPattern

| 메소드 | 시그니처 | 설명 |
|------|----------|------|
| extractAddresses(from:) | static func extractAddresses(from text: String) -> [String] | 도로명 / 지번 주소 모두 추출 |
| extractStreetAddresses(from:) | static func extractStreetAddresses(from text: String) -> [String] | 도로명 주소만 추출 |
| extractLotAddresses(from:) | static func extractLotAddresses(from text: String) -> [String] | 지번 주소만 추출 |
| normalize(_:) | static func normalize(_ address: String) -> String | 주소 정규화 |
| isValidAddress(_:) | static func isValidAddress(_ address: String) -> Bool | 주소 유효성 검증 |

---

### DuplicateCounter

| 메소드 | 시그니처 | 설명 |
|------|----------|------|
| countDuplicates(_:) | static func countDuplicates(_ addresses: [String]) -> [String: Int] | 중복 카운팅 |
| mergeDictionaries(_:_:) | static func mergeDictionaries(_ dict1: [String: Int], _ dict2: [String: Int]) -> [String: Int] | 딕셔너리 병합 |
| topAddresses(_:topN:) | static func topAddresses(_ addresses: [String: Int], topN: Int) -> [(String, Int)] | 상위 N개 주소 반환 |

---

## 주소 추출 알고리즘

### 추출 우선순위

1. **테이블 기반** (`source: .table`)
   - 가로 헤더 탐색: 첫 행에서 `"주소"` 컬럼 탐색
   - 세로 헤더 탐색: 첫 열에서 `"주소"` 행 탐색
   - 전치(Transpose) 후 재탐색
   - Fallback: 전체 셀 스캔

2. **리스트 기반** (`source: .list`)
   - 각 리스트 항목에서 주소 패턴 매칭

3. **텍스트 기반** (`source: .text`)
   - 전체 텍스트에서 정규식 매칭

---

## 7. 파일 구조

> 해당되는 기능의 파일만 작성ScanLoadFeatureStateScanLoadFeatureStateScanListFeatureState
```
Sources/
├── 📁 Presentation/
│    ├── 🗂️ ScanLoadScene/
│    │    ├── 🗂️ SubViews/
│    │    │    └── LoadingAnimationView.swift          // 로딩 애니메이션
│    │    ├── ScanLoadFeature.swift                    
│    │    └── ScanLoadView.swift                       // 분석 화면
│    └── 🗂️ ScanListScene/
│         ├── 🗂️ DTO/
│         │    └── ScanResult.swift                    // 스캔 결과 모델
│         ├── 🗂️ Enum/
│         │    └── PinCategoryType.swift               // 핀 카테고리 (거주지/직장/기타)
│         ├── 🗂️ SubViews/
│         │    ├── 🗂️ Components/
│         │    │    └── ScanResultCard.swift           // 결과 카드 컴포넌트
│         │    └── ScanListHeader.swift                // 헤더 뷰
│         ├── ScanListFeature.swift                    
│         └── ScanListView.swift                       // 결과 목록 화면
└── 📁 Util/
     └── 🗂️ Vision/
          ├── 🗂️ Core/
          │    ├── BatchAddressAnalyzer.swift          // 다중 이미지 순차 분석
          │    ├── DocumentAnalyzer.swift              // Vision 문서 구조 분석
          │    └── DocumentDetectionProcessor.swift    // 실시간 문서/얼룩 감지 (actor)
          ├── 🗂️ DTO/
          │    ├── AddressExtractionResult.swift       // 주소 추출 결과 모델
          │    ├── DocumentAnalysisResult.swift        // 문서 분석 결과 모델
          │    ├── DocumentDetectionResult.swift       // 실시간 감지 결과
          │    └── LensSmudgeDetectionResult.swift     // 렌즈 얼룩 감지 결과
          ├── 🗂️ Enums/
          │    ├── DocumentDetectionError.swift        // 감지 에러 타입
          │    └── VisionAnalysisError.swift           // 분석 에러 타입
          ├── 🗂️ Extensions/
          │    ├── AddressExtractor.swift              // 테이블/텍스트 주소 추출
          │    ├── DuplicateCounter.swift              // 중복 카운팅 유틸
          │    └── KoreanAddressPattern.swift          // 한국 주소 정규식
          ├── 🗂️ Overlay/
          │    └── DocumentDetectionOverlayView.swift  // 문서 감지 오버레이 뷰
          ├── 🗂️ Protocol/
          │    └── VisionServiceProtocol.swift         // Vision 서비스 프로토콜
          ├── CameraModel+Vision.swift                 // CameraModel Vision Extension
          ├── VisionModel.swift                        // Vision 기능 관리 (@Observable)
          └── VisionService.swift                      // Vision 서비스 (Sendable)
```

---

## 8. 예외 상황 및 대응 기준

### 예외 상황 1: Vision 프로세스 초기화 실패 시

- **증상**: 문서 감지 오버레이가 표시되지 않음
- **원인**: 스트림 연결이 실패됐을 경우
- **대응**: CameraFeature에서 최대 5회 재시도 함


### 예외 상황 2: Geocode 검증 실패 시

- **증상**: 추출된 주소가 결과 목록에 없음
- **원인**: 유효하지 않은 주소, API 오류
- **대응**: 검증 실패 주소 제외, 성공한 주소만 표시

---

## 9. 기능 한계 및 주의사항

실시간 문서 감지
- 현재 실제 구현 기능은 렌즈 얼룩 여부 로직 적용된 상태임
- Vision 프로세서 초기화 및 에러 처리에 대한 방안 강구

문서 이미지 분석
- iOS 26+ 이상에서만 사용 가능
- 손글씨 및 저해상도 이미지에 대한 처리방안이 없음
- 테이블 구조가 불규칙 할 경우에 대한 고도화 필요 (현재는 Fallback)
- API 호출 시 네트워크 처리 필요

---

## 10. 향후 개선 사항

### 기능 고도화

- 실시간 문서 경계 감지 및 자동 촬영 기능 검토
- 더 많은 주소 패턴 지원필요
- 이미지 전처리(회전, 보정) 기능 검토
- 분석 속도 개선
- 추출된 주소의 이미지 정보 수집

### 기술 부채

- ``ScanLoadFeature``, ``ScanListFeature`` 전달 방식 개선
- 주소 정규식 복잡도 개선
- ``BatchAddressAnalyzer`` 병렬 처리 검토

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| --- | --- |
| 담당자 | Taeni |
| 관련 문서 | |

---

## Topics

### Core Components
- ``ScanLoadFeature``
- ``ScanListFeature``
- ``BatchAddressAnalyzer``
- ``DocumentAnalyzer``

### Address Extraction
- ``AddressExtractor``
- ``KoreanAddressPattern``
- ``DuplicateCounter``

### Realtime Detection
- ``DocumentDetectionProcessor``
- ``VisionService``
- ``CameraModel+Vision``

### Data Models
- ``ScanResult``
- ``AddressExtractionResult``
- ``DocumentAnalysisResult``
- ``PinCategoryType``
