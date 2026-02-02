# 카메라 촬영 기능 (Camera Feature)
[기능에 대한 한 줄 설명]

수사 문서 촬영 및 Vision 연동 실시간 분석 기능

> 📅 **작성일**: 2026.01.22  
> 👤 **작성자**: Taeni  
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명

카메라 촬영 기능

### 기능 정의

카메라 기능은 CameraModel 에서 서비스 계층을 분리하여 추상화하는 구조 설계되어있으며,
State는 문서 이미지를 분석하고 주소를 추출하는 기능이 포함되어 있음

AVFoundation 활용하여 카메라 기능을 제공
1. 카메라 프리뷰 제공 및 촬영
2. 카메라 제어 (줌, autoFocus)
3. Vision 연동 (렌즈 얼룩 감지 실시간 반영)

핵심 아키텍쳐:
- CameraFeature : UI상태 관리 및 사용자 인터랙션 처리
- CameraModel : 카메라 기능 통합 관리, 서비스 계층
- 서비스 레이어 : 권한, 세션, 프레임, 촬영, 디바이스 제어


### 도입 목적

- 문서 이미지 촬영 : 수사 문서를 촬영하여 주소 추출에 활용
- 렌즈 상태 확인 : 렌즈 얼룩 감지 알림으로 사용자에게 선명한 이미지를 촬영할 수 있도록 제공
- 다중 촬영 : 최대 10장 촬영으로 대량 처리

---

## 2. 기능 적용 범위

### 사용 위치

1. MainTab > MapScene > CameraScene
2. MapScene(지도 화면)에서 카메라 아이콘 탭 시 진입

### 사용자 관점 동작 조건

1. 사용자가 **[카메라 버튼을 탭]**하면 ``[CameraView]``로 [이동]한다.
2. ``[CameraView]`` 에서 카메라 권한을 확인하고 프리뷰가 [시작]된다.
3. 촬영 버튼을 탭하면 사진이 촬영되고 썸네일이 [업데이트]된다.
4. **[썸네일을 탭]**하면 ``[PhotoDetailsView]``에서 촬영된 사진을 [조회]하거나 [삭제]한다.
5. **[스캔 버튼을 탭]**하면 ``[ScanLoadView]`` 로 [이동]한다.

| 인터랙션 | 동작 | 결과 |
|----------|------|------|
| 카메라 버튼 탭 | CameraView로 화면 전환 | 카메라 권한 확인 후 프리뷰 시작 |
| 촬영 버튼 탭 | 사진 촬영 실행 | 썸네일 업데이트, 촬영 카운트 증가 |
| 화면 Pinch In/Out | 줌 조절 | 1.0 ~ 12.0배 범위 내 줌 변경 |
| 화면 Tap | 탭 위치 포커스 | 해당 좌표에 오토포커스 적용 |
| 썸네일 버튼 탭 | PhotoDetailsView로 이동 | 촬영된 사진 조회 / 삭제 가능 |
| 스캔 버튼 탭 | ScanLoadView로 이동 | Vision 분석 시작, 주소 추출 진행 |
| 뒤로가기 탭 (사진 있음) | 확인 Alert 표시 | 확인 시 사진 삭제 후 이전 화면 |
| 뒤로가기 탭 (사진 없음) | 즉시 이전 화면 이동 | MapView로 복귀 |

---

## 3. 화면 흐름도 (Screen Flow)

>  이미지 활용

![Camera 화면 흐름도](../../Resources/Camera/camera-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

![Camera 시퀀스 다이어그램](../../Resources/Camera/camera-sequence.svg)

### 4.2 흐름 설명

4.2 흐름 설명

1. 카메라 시작
CameraView가 나타나면 .onAppear → .viewDidAppear 액션이 순차 발생
CameraModel.start()가 호출되어 권한 확인 → 디바이스 선택 → 세션 구성 → 프레임 스트림 설정
Vision 분석이 활성화되어 렌즈 얼룩 감지 스트림 시작

2. 사진 촬영 (Photo Capture)
.captureButtonTapped 액션 발생 시 isCapturing = true로 연속 탭 방지
PhotoCaptureService.capturePhoto()가 AVCapturePhotoOutput을 통해 촬영
촬영 완료 후 .syncPhotoState → .updatePhotoCount → .updateThumbnail → .updateAllPhotos 체인 실행

3. 줌/포커스 제어 (Device Control)
Pinch 제스처: delta = scale / lastZoomScale 계산 후 CameraControlService.applyPinchZoom() 호출
Tap 제스처: 정규화된 좌표 (0~1)로 변환 후 CameraControlService.focusOnPoint() 호출

4. Vision 연동 (Realtime Detection)
DocumentDetectionProcessor가 프레임 스트림을 구독하여 매 10프레임(3fps)마다 분석
렌즈 얼룩 감지 시 .updateLensSmudgeDetection → Toast 표시 (중복 방지 플래그 사용)

---

## 5. 상태 다이어그램 (State Diagram)

![Camera 상태 다이어그램](../../Resources/Camera/camera-status-state.svg)

---

![Camera 촬영 상태 다이어그램](../../Resources/Camera/camera-capture-state.svg)


---

## 6. 의존성 다이어그램 (Dependency Diagram)

![Camera 의존성 다이어그램](../../Resources/Camera/camera-dependency.svg)


## 서비스 레이어 역할

- **CameraPermissionService** (`class`)
  - 카메라 권한 요청 및 상태 확인 담당
  - 최초 실행 시 권한 요청 플로우 관리
  - 권한 거부 / 제한 상태 판별

- **CameraCaptureSession** (`actor`)
  - `AVCaptureSession` 생명주기 관리
  - 입력 / 출력 디바이스 구성
  - 세션 시작 / 중지 및 상태 전환 처리

- **CameraFrameProvider** (`class`)
  - 카메라 프레임 스트림 제공
  - `AsyncStream<CVImageBuffer>` 기반 프레임 전달
  - Vision 및 Preview 레이어에 프레임 공급

- **CameraControlService** (`actor`)
  - 카메라 하드웨어 제어 전담
  - 줌(Zoom), 토치(Torch), 포커스(Focus) 제어
  - 디바이스 기능별 제약 조건 캡슐화

- **PhotoCaptureService** (`@Observable class`)
  - 사진 촬영 로직 관리
  - 촬영 결과 저장 및 삭제 처리
  - 썸네일, 촬영 개수 등 상태 관리


---

### CameraModel

| 카테고리 | 메소드 | 시그니처 | 설명 |
|---------|--------|----------|------|
| Lifecycle | start | func start() async | 카메라 시작 (권한 → 디바이스 → 세션 → 프레임) |
| Lifecycle | stop | func stop() async | 카메라 중지 및 리소스 정리 |
| Lifecycle | pauseCamera | func pauseCamera() | 카메라 일시정지 |
| Lifecycle | resumeCamera | func resumeCamera() | 카메라 재개 |
| Photo | capturePhoto | func capturePhoto() async throws -> CapturedPhoto | 사진 촬영 |
| Photo | getAllPhotos | func getAllPhotos() -> [CapturedPhoto] | 전체 사진 반환 |
| Photo | deletePhoto(at:) | func deletePhoto(at index: Int) | 특정 인덱스 사진 삭제 |
| Photo | clearAllPhotos | func clearAllPhotos() | 전체 사진 삭제 |
| Photo | getLastThumbnail | func getLastThumbnail() -> UIImage? | 마지막 썸네일 반환 |
| Control | setZoom(to:) | func setZoom(to factor: CGFloat) async | 줌 설정 (1.0 ~ 12.0) |
| Control | applyPinchZoom(delta:) | func applyPinchZoom(delta: CGFloat) async | Pinch 줌 적용 |
| Control | resetZoom | func resetZoom() async | 줌 초기화 (1.0) |
| Control | getZoomRange | func getZoomRange() async -> ClosedRange<CGFloat> | 줌 범위 반환 |
| Control | toggleTorch | func toggleTorch() async | Torch 토글 |
| Control | turnOnTorch | func turnOnTorch() async | Torch 켜기 |
| Control | turnOffTorch | func turnOffTorch() async | Torch 끄기 |
| Control | focusOnPoint(_:) | func focusOnPoint(_ point: CGPoint) async | 포인트 포커스 |
| Stream | getFrameStream | func getFrameStream() -> AsyncStream<CVImageBuffer>? | 프레임 스트림 반환 |

---

### CameraModel + Vision

| 메소드 | 시그니처 | 설명 |
|-------|----------|------|
| enableVisionAnalysis | func enableVisionAnalysis() | Vision 분석 활성화, DocumentDetectionProcessor 초기화 |
| startVisionAnalysis | func startVisionAnalysis() async | 프레임 스트림 구독 시작, Vision 분석 실행 |
| getDocumentDetectionStream | func getDocumentDetectionStream() -> AsyncStream<DocumentDetectionResult>? | 문서 감지 결과 스트림 반환 |
| getLensSmudgeStream | func getLensSmudgeStream() -> AsyncStream<LensSmudgeDetectionResult>? | 렌즈 얼룩 감지 스트림 반환 |
| stopVisionAnalysis | func stopVisionAnalysis() | Vision 분석 중지 및 리소스 정리 |

---

### CameraControlService (actor)

| 메소드 | 시그니처 | 설명 |
|-------|----------|------|
| selectBackCamera | func selectBackCamera() | 후면 카메라 선택 (DualWide → Triple → WideAngle 우선순위) |
| setZoom(to:) | func setZoom(to factor: CGFloat) -> CGFloat | 줌 설정, 실제 적용된 값 반환 |
| applyPinchZoom(delta:) | func applyPinchZoom(delta: CGFloat) -> CGFloat | 상대적 줌 조절 |
| turnOnTorch | func turnOnTorch() -> Bool | Torch 켜기 (성공 여부 반환) |
| turnOffTorch | func turnOffTorch() -> Bool | Torch 끄기 |
| toggleTorch | func toggleTorch() -> Bool | Torch 토글 (최종 상태 반환) |
| focusOnPoint(_:) | func focusOnPoint(_ point: CGPoint) | 특정 포인트 포커스 및 노출 설정 |

---


## 7. 파일 구조

> 해당되는 기능의 파일만 작성
```
Sources/
├── 📁 Presentation/
│    ├── 🗂️ CameraScene/
│    │    ├── 🗂️ Models/
│    │    │    └── CapturedPhoto+.swift               // CapturedPhoto Extension
│    │    ├── 🗂️ SubViews/
│    │    │    ├── 🗂️ Components/
│    │    │    │    ├── CaptureButton.swift           // 촬영 버튼 (비활성화 상태 처리)
│    │    │    │    ├── CircleBadgeModifier.swift     // 원형 배지 ViewModifier
│    │    │    │    └── ThumbnailButton.swift         // 썸네일 버튼 (카운트 배지)
│    │    │    ├── CameraController.swift             // 하단 컨트롤러 (촬영+썸네일)
│    │    │    └── CameraHeader.swift                 // 상단 헤더 (뒤로가기, 스캔)
│    │    ├── CameraFeature.swift                     
│    │    └── CameraView.swift                        // 메인 카메라 화면
│    └── 🗂️ PhotoDetailsScene/
│         ├── 🗂️ Enum/
│         │    └── ZoomState.swift                    // 줌/드래그 상태 관리
│         ├── 🗂️ SubViews/
│         │    ├── PhotoDetailsHeader.swift           // 헤더 (인덱스, 삭제)
│         │    └── ZoomableImageView.swift            // 확대/축소 가능한 이미지 뷰
│         ├── PhotoDetailsFeature.swift              
│         └── PhotoDetailsView.swift                  // 사진 상세 화면
└── 📁 Util/
     ├── 🗂️ Camera/
     │    ├── 🗂️ Core/
     │    │    ├── CameraCaptureSession.swift         // AVCaptureSession 관리 (actor)
     │    │    ├── CameraControlService.swift         // 줌/토치/포커스 제어 (actor)
     │    │    ├── CameraFrameProvider.swift          // 프레임 스트림 제공
     │    │    ├── CameraPermissionService.swift      // 권한 관리
     │    │    └── PhotoCaptureService.swift          // 사진 촬영 서비스 (@Observable)
     │    ├── 🗂️ Enums/
     │    │    ├── CameraSessionError.swift           // 세션 에러 타입
     │    │    ├── CameraStatus.swift                 // 카메라 상태 Enum
     │    │    └── PhotoCaptureError.swift            // 촬영 에러 타입
     │    ├── 🗂️ Models/
     │    │    └── CapturedPhoto.swift              
     │    ├── 🗂️ Views/
     │    │    ├── CameraPreview.swift                // UIViewRepresentable 프리뷰
     │    │    └── CameraSampleView.swift             // 카메라 샘플/테스트 뷰
     │    └── CameraModel.swift                       // 통합 카메라 모델 (@MainActor @Observable)
     └── 🗂️ Vision/
          └── CameraModel+Vision.swift                // Vision 분석 Extension
```
---

## 8. 예외 상황 및 대응 기준

### 예외 상황 1: 카메라 권한 거부 시

- **증상**: 카메라 프리뷰가 표시 되지 않음
- **원인**: 사용자의 권한 거부
- **대응**: 설정 앱으로 이동 안내 기능 추가 필요

### 예외 상황 2: CameraSession 구성 실패 시

- **증상**: 카메라 시작 되지 않음
- **원인**: 디바이스 출력 실패 시
- **대응**: 기능 추가 필요

### 예외 상황 3: 최대 촬영 개수 초과 시

- **증상**: 촬영 버튼이 비활성화 됨
- **원인**: 최대 촬영 가능 장수 10장 제한
- **대응**: PhotoCaptureErro.maxPhotosExceeded 에러 처리, Toast 메세지 표시

---

## 9. 기능 한계 및 주의사항

- 현재 촬영된 문서 이미지는 저장되지 않음, 메모리 관리 목적으로 최대 10장까지 촬영 가능함
- Vision 분석은 현재 매 10프레임마다 처리(3fps)
- 백그라운드 진입 시 카메라 세션이 자동으로 일시정지 처리됨
- 줌 범위는 현재 강제로 고정되어있음

---

## 10. 향후 개선 사항

### 기능 고도화

- 촬영 중에도 문서 인식 및 텍스트 인식 검증 로직 검토 필요
- 이미지 전처리 기능(회전, 밝기 보정 등)에 대한 기능 추가 필요
- 자동 문서 경계 감지 후 자동 촬영 기능 검토 필요

### 기술 부채

- PhotoDetailsFeature 에서 CameraModel 을 참조하는 의존성 문제 해결 필요
- 문서 감지 오버레이 코드는 현재 사용하고 있지 않음

---

## 11. 담당 및 참고 정보

| 항목 | 내용 |
| --- | --- |
| 담당자 | Taeni |
| 관련 문서 | |

---

## Topics

### Core Components
- ``CameraFeature``
- ``CameraModel``
- ``CameraView``

### Service Layer
- ``CameraPermissionService``
- ``CameraCaptureSession``
- ``CameraFrameProvider``
- ``CameraControlService``
- ``PhotoCaptureService``

### Vision Integration
- ``CameraModel+Vision``
- ``DocumentDetectionProcessor``

### Data Models
- ``CapturedPhoto``
- ``CameraStatus``
