# 카메라 촬영 기능 (Camera Feature)
[기능에 대한 한 줄 설명]

> 📅 **작성일**: 2026.01.22  
> 👤 **작성자**: Taeni
> 🏷️ **버전**: v1.0

## 1. 기능 개요

### 기능명

카메라 촬영 기능

### 기능 정의

>  **작성 가이드**: 심볼 링크(``ClassName``)를 활용해 데이터 흐름을 서술형으로 설명

카메라 기능은 ameraModel 에서 서스 계층을 분리하여 추상화하는 구조 설계되어있으며,
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
>  **작성 가이드**: 왜 이 기능이 필요한지 작성

- 문서 이미지 촬영 : 수사 문서를 촬영하여 주소 추출에 활용
- 렌즈 상태 확인 : 렌즈 얼룩 감지 알림으로 사용자에게 선명한 이미지를 촬영할 수 있도록 제공
- 다중 촬영 : 최대 10장 촬영으로 대량 처리

---

## 2. 기능 적용 범위

### 사용 위치

>  **작성 가이드**: 이 기능이 동작하는 화면/상황을 체크

1. MainTab > MapScene > CameraScene
2. MapScene(지도 화면)에서 카메라 아이콘 탭 시 진입

### 사용자 관점 동작 조건

> **작성 가이드**: 사용자 행동 → 시스템 반응 순서로 작성

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

![Camera 화면 흐름도](Camera/camera-flow.svg)

---

## 4. 기능 전체 흐름

### 4.1 시퀀스 다이어그램

> mermaid 활용

![Camera 시퀀스 다이어그램](Camera/camera-sequence.svg)

### 4.2 흐름 설명

> **작성 가이드**: 심볼 링크를 활용해 컴포넌트 간 데이터 흐름을 설명

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

> Mermaid 활용


![Camera 상태 다이어그램](Camera/camera-status-state.svg)


![Camera 촬영 상태 다이어그램](Camera/camera-capture-state.svg)


---

## 6. 의존성 다이어그램 (Dependency Diagram)

> Mermaid 활용
![Camera 의존성 다이어그램](Camera/camera-dependency.svg)

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

>  **작성 가이드**: 에러처리가 되어있는 부분만 작성

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

> **작성 가이드**: 현재 기능의 한계점이나 주의사항 작성

- 현재 촬영된 문서 이미지는 저장되지 않음, 메모리 관리 목적으로 최대 10장까지 촬영 가능함
- Vision 분석은 현재 매 10프레임마다 처리(3fps)
- 백그라운드 진입 시 카메라 세션이 자동으로 일시정지 처리됨
- 줌 범위는 현재 강제로 고정되어있음

---

## 10. 향후 개선 사항

### 기능 고도화
> **작성 가이드**: 추가하고 싶은 기능 작성

- 촬영 중에도 문서 인식 및 텍스트 인식 검증 로직 검토 필요
- 이미지 전처리 기능(회전, 밝기 보정 등)에 대한 기능 추가 필요
- 자동 문서 경계 감지 후 자동 촬영 기능 검토 필요

### 기술 부채
> **작성 가이드**: 리팩토링이 필요한 부분 작성

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
>  **작성 가이드**: 핵심 컴포넌트를 심볼 링크로 나열

- ``Component1``
- ``Component2``

### [카테고리명]
[카테고리 설명]

- ``Component``

### Data Models
[모델 설명]

- ``Model``
