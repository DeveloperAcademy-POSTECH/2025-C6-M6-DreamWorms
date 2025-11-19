# 맵 기능 추가 가이드

이 문서는 NaverMap 모듈에 새로운 기능을 추가하는 방법을 설명합니다. 아키텍처 구조를 이해하고 올바른 컴포넌트에 기능을 통합하는 방법을 단계별로 안내합니다.

## 개요

NaverMap 모듈은 Facade 패턴을 사용하여 복잡한 지도 기능을 단순한 인터페이스로 제공합니다. 새로운 기능을 추가할 때는 다음 계층 구조를 따라야 합니다:

```
MapView (SwiftUI)
    ↓
NaverMapView (UIViewRepresentable)
    ↓
Coordinator (Delegate 처리)
    ↓
MapFacade (Facade 패턴)
    ↓
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ Controller  │   Handler   │   Service   │   Updater   │
│             │             │             │             │
│ - Camera    │ - Touch     │ - Data      │ - Layer     │
│ - Location  │             │             │             │
└─────────────┴─────────────┴─────────────┴─────────────┘
                    ↓
              Manager (리소스 관리)
```

## 아키텍처 구조

### 폴더 구조

```
Sources/Util/NaverMap/
├── Controller/          # 제어 (카메라, 위치)
│   ├── MapCameraController.swift
│   └── MapLocationController.swift
├── Handler/             # 이벤트 처리 (터치)
│   └── MapTouchHandler.swift
├── Utility/             # 유틸리티
│   ├── MapDataService.swift      # 데이터 변환/조회
│   ├── MapLayerUpdater.swift     # 레이어 업데이트
│   └── MapTouchHandler.swift     # 터치 이벤트
├── Manager/             # 리소스 관리
│   ├── CaseLocationMarkerManager.swift
│   └── InfrastructureLayerManager.swift
├── Facade/              # Facade 패턴
│   └── MapFacade.swift
└── NaverMapView.swift   # SwiftUI 래퍼
```

### 컴포넌트 역할

- **Controller**: 지도 제어 기능 (카메라 이동, 위치 추적)
- **Handler**: 사용자 이벤트 처리 (터치, 제스처)
- **Service**: 데이터 변환 및 조회 (순수 함수)
- **Updater**: 레이어 및 UI 상태 업데이트
- **Manager**: 리소스 관리 (마커, 오버레이)
- **Facade**: 모든 컴포넌트를 통합하고 단순한 인터페이스 제공

## 기능 타입 판단

새로운 기능을 추가하기 전에, 해당 기능이 어떤 타입의 컴포넌트에 속하는지 판단해야 합니다.

### Controller 타입

지도를 제어하는 기능입니다.

**특징**:
- 카메라 이동, 줌, 회전
- 위치 추적, 현위치 포커싱
- 지도 설정 변경

**예시**:
- `MapCameraController`: 카메라 이동, 줌 제어
- `MapLocationController`: 위치 추적, 현위치 포커싱

**추가 위치**: `Controller/` 폴더

### Handler 타입

사용자 이벤트를 처리하는 기능입니다.

**특징**:
- 터치 이벤트
- 제스처 이벤트
- 롱프레스, 더블탭 등

**예시**:
- `MapTouchHandler`: 맵 터치 이벤트 처리

**추가 위치**: `Handler/` 폴더 또는 `Utility/` 폴더

### Service 타입

순수 함수 또는 데이터 변환/조회 기능입니다.

**특징**:
- 상태 없음 (stateless)
- 입력 → 출력 변환
- 데이터 조회, 계산

**예시**:
- `MapDataService`: 데이터 변환, 해시 계산, 조회

**추가 위치**: `Utility/` 폴더

### Updater 타입

레이어나 UI 상태를 업데이트하는 기능입니다.

**특징**:
- 마커 표시/숨김
- 오버레이 업데이트
- 레이어 동기화

**예시**:
- `MapLayerUpdater`: 레이어 업데이트, 마커 표시 제어

**추가 위치**: `Utility/` 폴더

### Manager 타입

리소스를 관리하는 기능입니다.

**특징**:
- 마커 생성/삭제/업데이트
- 오버레이 관리
- 캐시 관리

**예시**:
- `CaseLocationMarkerManager`: 사용자 위치 마커 관리
- `InfrastructureMarkerManager`: 인프라 마커 관리

**추가 위치**: `Manager/` 폴더

## 단계별 추가 가이드

### Step 1: 기능 타입 판단 및 컴포넌트 선택

다음 질문을 통해 기능의 타입을 판단합니다:

1. 이 기능이 무엇을 하는가?
2. 어떤 타입에 속하는가? (Controller/Handler/Service/Updater/Manager)
3. 기존 컴포넌트에 추가할 수 있는가? 아니면 새로 만들어야 하는가?

### Step 2: 컴포넌트에 기능 추가

#### 기존 컴포넌트에 추가하는 경우

기존 컴포넌트의 역할과 일치하는 기능은 해당 컴포넌트에 추가합니다.

**예시: MapCameraController에 줌 인/아웃 기능 추가**

```swift
// Controller/MapCameraController.swift

// MARK: - Zoom Control

/// 줌 레벨을 증가시킵니다.
func zoomIn(by level: Double = 1.0) {
    guard let mapView else { return }
    let currentZoom = mapView.zoomLevel
    let newZoom = min(currentZoom + level, mapView.maxZoomLevel)
    let cameraUpdate = NMFCameraUpdate(zoomTo: newZoom)
    cameraUpdate.animation = .easeOut
    cameraUpdate.animationDuration = MapConstants.cameraAnimationDuration
    mapView.moveCamera(cameraUpdate)
}

/// 줌 레벨을 감소시킵니다.
func zoomOut(by level: Double = 1.0) {
    guard let mapView else { return }
    let currentZoom = mapView.zoomLevel
    let newZoom = max(currentZoom - level, mapView.minZoomLevel)
    let cameraUpdate = NMFCameraUpdate(zoomTo: newZoom)
    cameraUpdate.animation = .easeOut
    cameraUpdate.animationDuration = MapConstants.cameraAnimationDuration
    mapView.moveCamera(cameraUpdate)
}
```

#### 새로운 컴포넌트를 만드는 경우

기존 컴포넌트와 역할이 다른 경우 새로운 컴포넌트를 생성합니다.

**예시: MapGestureHandler 생성 (제스처 처리)**

```swift
// Handler/MapGestureHandler.swift

import Foundation
import NMapsMap

/// 맵 제스처 이벤트 처리를 담당하는 핸들러
@MainActor
final class MapGestureHandler {
    // MARK: - Properties
    
    weak var mapView: NMFMapView?
    var onLongPress: ((NMGLatLng) -> Void)?
    var onDoubleTap: ((NMGLatLng) -> Void)?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Gesture Handling
    
    func handleLongPress(at latlng: NMGLatLng) {
        onLongPress?(latlng)
    }
    
    func handleDoubleTap(at latlng: NMGLatLng) {
        onDoubleTap?(latlng)
    }
}
```

### Step 3: MapFacade에 통합

모든 맵 기능은 `MapFacade`를 통해 접근 가능해야 합니다. `MapFacade`는 모든 컴포넌트를 관리하고 단순한 인터페이스를 제공합니다.

#### 컴포넌트를 MapFacade의 프로퍼티로 추가

```swift
// Facade/MapFacade.swift

@MainActor
final class MapFacade {
    // MARK: - Components
    
    private let cameraController: MapCameraController
    private let locationController: MapLocationController
    private let touchHandler: MapTouchHandler
    private let layerUpdater: MapLayerUpdater
    private let gestureHandler: MapGestureHandler
    
    // MARK: - Initialization
    
    init(
        infrastructureManager: InfrastructureMarkerManager,
        caseLocationMarkerManager: CaseLocationMarkerManager
    ) {
        self.infrastructureManager = infrastructureManager
        self.caseLocationMarkerManager = caseLocationMarkerManager
        
        // Facade가 모든 컴포넌트 생성
        self.cameraController = MapCameraController()
        self.locationController = MapLocationController()
        self.touchHandler = MapTouchHandler()
        self.gestureHandler = MapGestureHandler()
        self.layerUpdater = MapLayerUpdater(
            infrastructureManager: infrastructureManager,
            caseLocationMarkerManager: caseLocationMarkerManager
        )
        
        // 기본 설정
        cameraController.defaultZoomLevel = MapConstants.defaultZoomLevel
    }
}
```

#### MapFacade에 public 메서드 추가

외부에서 사용할 수 있도록 public 메서드를 추가합니다.

```swift
// Facade/MapFacade.swift

// MARK: - Zoom Control

/// 줌 인을 수행합니다.
func zoomIn(by level: Double = 1.0) {
    cameraController.zoomIn(by: level)
}

/// 줌 아웃을 수행합니다.
func zoomOut(by level: Double = 1.0) {
    cameraController.zoomOut(by: level)
}

// MARK: - Gesture Handling

/// 롱프레스 이벤트를 처리합니다.
func handleLongPress(at latlng: NMGLatLng) {
    gestureHandler.handleLongPress(at: latlng)
}
```

#### update 메서드에 통합

`update` 메서드는 SwiftUI의 `updateUIView`에서 호출되며, 모든 컴포넌트의 상태를 동기화합니다.

```swift
// Facade/MapFacade.swift

func update(
    mapView: NMFMapView,
    cameraTarget: MapCoordinate?,
    shouldAnimateCamera: Bool,
    onCameraMoveConsumed: (() -> Void)?,
    shouldFocusMyLocation: Bool,
    onMyLocationFocusConsumed: (() -> Void)?,
    isMapTouchEnabled: Bool,
    isTimelineSheetMinimized: Bool,
    layerData: LayerData,
    deselectMarkerTrigger: UUID?,
    lastDeselectMarkerTrigger: inout UUID?,
    onDeselectMarker: @escaping () async -> Void
) {
    // 1) 의존성 주입
    cameraController.mapView = mapView
    locationController.mapView = mapView
    gestureHandler.mapView = mapView
    
    // 2) 터치 핸들러 상태 업데이트
    touchHandler.isMapTouchEnabled = isMapTouchEnabled
    touchHandler.isTimelineSheetMinimized = isTimelineSheetMinimized
    
    // ... 나머지 로직
}
```

#### configureCallbacks에 콜백 추가

이벤트 콜백이 필요한 경우 `configureCallbacks` 메서드에 추가합니다.

```swift
// Facade/MapFacade.swift

func configureCallbacks(
    onCameraIdle: @escaping (MapBounds, Double) -> Void,
    onInitialLocation: @escaping (MapCoordinate) -> Void,
    onMapTapped: @escaping (NMGLatLng) -> Void,
    onMarkerDeselect: @escaping () async -> Void,
    onCellMarkerTapped: @escaping (String, String?) -> Void,
    onUserLocationMarkerTapped: @escaping (UUID) -> Void,
    onLongPress: @escaping (NMGLatLng) -> Void,
    onDoubleTap: @escaping (NMGLatLng) -> Void
) {
    cameraController.onCameraIdle = onCameraIdle
    
    locationController.onInitialLocation = { [weak self] coordinate in
        onInitialLocation(coordinate)
        self?.cameraController.moveCamera(to: coordinate)
    }
    
    touchHandler.onMapTapped = onMapTapped
    touchHandler.onMarkerDeselect = onMarkerDeselect
    
    layerUpdater.onCellMarkerTapped = onCellMarkerTapped
    layerUpdater.onUserLocationMarkerTapped = onUserLocationMarkerTapped
    
    gestureHandler.onLongPress = onLongPress
    gestureHandler.onDoubleTap = onDoubleTap
}
```

### Step 4: NaverMapView에 노출

`NaverMapView`는 SwiftUI와 UIKit을 연결하는 브릿지 역할을 합니다. 새로운 기능을 SwiftUI에서 사용할 수 있도록 프로퍼티와 콜백을 추가합니다.

#### NaverMapView에 프로퍼티 추가

```swift
// NaverMapView.swift

struct NaverMapView: UIViewRepresentable {
    // MARK: - Zoom Control
    
    /// 줌 인 명령 트리거
    var zoomInTrigger: UUID?
    
    /// 줌 아웃 명령 트리거
    var zoomOutTrigger: UUID?
    
    // MARK: - Gesture Callbacks
    
    /// 롱프레스 이벤트 콜백
    var onLongPress: ((NMGLatLng) -> Void)?
    
    /// 더블탭 이벤트 콜백
    var onDoubleTap: ((NMGLatLng) -> Void)?
}
```

#### Coordinator에 콜백 설정

`Coordinator`는 UIKit의 Delegate를 처리합니다. 새로운 이벤트 콜백을 설정합니다.

```swift
// NaverMapView.swift

class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
    weak var mapView: NMFMapView?
    let parent: NaverMapView
    let facade: MapFacade
    var lastDeselectMarkerTrigger: UUID?
    var lastZoomInTrigger: UUID?
    var lastZoomOutTrigger: UUID?

    init(
        parent: NaverMapView,
        infrastructureManager: InfrastructureMarkerManager,
        caseLocationMarkerManager: CaseLocationMarkerManager
    ) {
        self.parent = parent
        
        self.facade = MapFacade(
            infrastructureManager: infrastructureManager,
            caseLocationMarkerManager: caseLocationMarkerManager
        )
        
        super.init()
        
        facade.configureCallbacks(
            onCameraIdle: { [weak self] bounds, zoomLevel in
                self?.parent.onCameraIdle?(bounds, zoomLevel)
            },
            onInitialLocation: { _ in
                // 초기 위치는 Facade 내부에서 카메라 이동 처리
            },
            onMapTapped: { [weak self] latlng in
                self?.parent.onMapTapped?(latlng)
            },
            onMarkerDeselect: { [weak self] in
                guard let self, let mapView = self.mapView else { return }
                await facade.deselectMarker(on: mapView)
            },
            onCellMarkerTapped: { [weak self] (cellKey: String, _: String?) in
                guard let self else { return }
                Task { @MainActor in
                    let title = MapDataService.findCellTitle(by: cellKey, in: self.parent.cellStations)
                    self.parent.onCellMarkerTapped?(cellKey, title)
                }
            },
            onUserLocationMarkerTapped: { [weak self] locationId in
                guard let self else { return }
                self.parent.onUserLocationMarkerTapped?(locationId)
            },
            onLongPress: { [weak self] latlng in
                self?.parent.onLongPress?(latlng)
            },
            onDoubleTap: { [weak self] latlng in
                self?.parent.onDoubleTap?(latlng)
            }
        )
    }
}
```

#### updateUIView에서 처리

SwiftUI 상태 변경 시 `updateUIView`가 호출됩니다. 새로운 기능의 상태를 처리합니다.

```swift
// NaverMapView.swift

func updateUIView(_ uiView: NMFMapView, context: Context) {
    context.coordinator.mapView = uiView
    
    let layerData = MapFacade.LayerData(
        cellStations: cellStations,
        locations: locations,
        cctvMarkers: cctvMarkers,
        isCellLayerEnabled: isCellLayerEnabled,
        isCCTVLayerEnabled: isCCTVLayerEnabled,
        isVisitFrequencyEnabled: isVisitFrequencyEnabled,
        isCellRangeVisible: isCellRangeVisible,
        cellCoverageRange: cellCoverageRange
    )

    // 줌 제어 처리
    if let trigger = zoomInTrigger, trigger != context.coordinator.lastZoomInTrigger {
        context.coordinator.lastZoomInTrigger = trigger
        context.coordinator.facade.zoomIn()
    }
    
    if let trigger = zoomOutTrigger, trigger != context.coordinator.lastZoomOutTrigger {
        context.coordinator.lastZoomOutTrigger = trigger
        context.coordinator.facade.zoomOut()
    }

    context.coordinator.facade.update(
        mapView: uiView,
        cameraTarget: cameraTargetCoordinate,
        shouldAnimateCamera: shouldAnimateCameraTarget,
        onCameraMoveConsumed: onCameraMoveConsumed,
        shouldFocusMyLocation: shouldFocusMyLocation,
        onMyLocationFocusConsumed: onMyLocationFocusConsumed,
        isMapTouchEnabled: isMapTouchEnabled,
        isTimelineSheetMinimized: isTimelineSheetMinimized,
        layerData: layerData,
        deselectMarkerTrigger: deselectMarkerTrigger,
        lastDeselectMarkerTrigger: &context.coordinator.lastDeselectMarkerTrigger,
        onDeselectMarker: { await context.coordinator.facade.deselectMarker(on: uiView) }
    )
}
```

#### Delegate 메서드 추가

Naver Map SDK의 Delegate 메서드가 필요한 경우 `Coordinator`에 추가합니다.

```swift
// NaverMapView.swift

class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
    // 롱프레스 처리 (실제로는 제스처 인식기 필요)
    func mapView(_ mapView: NMFMapView, didLongPressMap latlng: NMGLatLng) {
        facade.handleLongPress(at: latlng)
    }
}
```

### Step 5: MapView/MapFeature에서 사용

최종적으로 SwiftUI 뷰와 Redux 패턴의 Feature에서 새로운 기능을 사용합니다.

#### MapView에서 NaverMapView에 전달

```swift
// Presentation/MapScene/MapView.swift

NaverMapView(
    cameraTargetCoordinate: store.state.cameraTarget,
    shouldAnimateCameraTarget: store.state.shouldAnimateCamera,
    onCameraMoveConsumed: {
        store.send(.cameraMoveConsumed)
    },
    shouldFocusMyLocation: store.state.shouldFocusMyLocation,
    onMyLocationFocusConsumed: {
        store.send(.myLocationFocusConsumed)
    },
    zoomInTrigger: store.state.zoomInTrigger,
    zoomOutTrigger: store.state.zoomOutTrigger,
    onLongPress: { latlng in
        store.send(.longPress(latlng))
    },
    onDoubleTap: { latlng in
        store.send(.doubleTap(latlng))
    },
    // ... 기타 파라미터들
)
```

#### MapFeature에 Action/State 추가

Redux 패턴에 따라 State와 Action을 추가합니다.

```swift
// Presentation/MapScene/MapFeature.swift

struct State: DWState {
    // ... 기존 상태들
    var zoomInTrigger: UUID?
    var zoomOutTrigger: UUID?
}

enum Action: DWAction {
    // ... 기존 액션들
    case zoomIn
    case zoomOut
    case longPress(NMGLatLng)
    case doubleTap(NMGLatLng)
}

func reduce(_ state: inout State, action: Action) -> DWEffect {
    switch action {
    // ... 기존 케이스들
    
    case .zoomIn:
        state.zoomInTrigger = UUID()
        return .none
    
    case .zoomOut:
        state.zoomOutTrigger = UUID()
        return .none
    
    case let .longPress(latlng):
        // 롱프레스 처리 로직
        return .none
    
    case let .doubleTap(latlng):
        // 더블탭 처리 로직
        return .none
    }
}
```

## 실전 예제

### 예제 1: 줌 인/아웃 버튼 추가

줌 인/아웃 버튼을 추가하여 지도를 확대/축소할 수 있게 하는 예제입니다.

#### Step 1: 기능 타입 판단

- **타입**: Controller (카메라 제어)
- **컴포넌트**: `MapCameraController`에 추가

#### Step 2: MapCameraController에 기능 추가

```swift
// Controller/MapCameraController.swift

// MARK: - Zoom Control

func zoomIn(by level: Double = 1.0) {
    guard let mapView else { return }
    let currentZoom = mapView.zoomLevel
    let newZoom = min(currentZoom + level, mapView.maxZoomLevel)
    let cameraUpdate = NMFCameraUpdate(zoomTo: newZoom)
    cameraUpdate.animation = .easeOut
    cameraUpdate.animationDuration = MapConstants.cameraAnimationDuration
    mapView.moveCamera(cameraUpdate)
}

func zoomOut(by level: Double = 1.0) {
    guard let mapView else { return }
    let currentZoom = mapView.zoomLevel
    let newZoom = max(currentZoom - level, mapView.minZoomLevel)
    let cameraUpdate = NMFCameraUpdate(zoomTo: newZoom)
    cameraUpdate.animation = .easeOut
    cameraUpdate.animationDuration = MapConstants.cameraAnimationDuration
    mapView.moveCamera(cameraUpdate)
}
```

#### Step 3: MapFacade에 통합

```swift
// Facade/MapFacade.swift

// MARK: - Zoom Control

func zoomIn(by level: Double = 1.0) {
    cameraController.zoomIn(by: level)
}

func zoomOut(by level: Double = 1.0) {
    cameraController.zoomOut(by: level)
}
```

#### Step 4: NaverMapView에 노출

```swift
// NaverMapView.swift

struct NaverMapView: UIViewRepresentable {
    var zoomInTrigger: UUID?
    var zoomOutTrigger: UUID?
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        // ... 기존 로직
        
        if let trigger = zoomInTrigger, trigger != context.coordinator.lastZoomInTrigger {
            context.coordinator.lastZoomInTrigger = trigger
            context.coordinator.facade.zoomIn()
        }
        
        if let trigger = zoomOutTrigger, trigger != context.coordinator.lastZoomOutTrigger {
            context.coordinator.lastZoomOutTrigger = trigger
            context.coordinator.facade.zoomOut()
        }
    }
    
    class Coordinator: ... {
        var lastZoomInTrigger: UUID?
        var lastZoomOutTrigger: UUID?
    }
}
```

#### Step 5: MapView/MapFeature에서 사용

```swift
// MapView.swift

Button("줌 인") {
    store.send(.zoomIn)
}

Button("줌 아웃") {
    store.send(.zoomOut)
}

NaverMapView(
    zoomInTrigger: store.state.zoomInTrigger,
    zoomOutTrigger: store.state.zoomOutTrigger,
    // ...
)

// MapFeature.swift

case .zoomIn:
    state.zoomInTrigger = UUID()
    return .none

case .zoomOut:
    state.zoomOutTrigger = UUID()
    return .none
```

### 예제 2: 새로운 마커 타입 추가

새로운 타입의 마커를 지도에 표시하는 예제입니다.

#### Step 1: 기능 타입 판단

- **타입**: Manager (리소스 관리)
- **컴포넌트**: 새로운 Manager 생성

#### Step 2: Manager 생성

```swift
// Manager/CustomMarkerManager.swift

import Foundation
import NMapsMap

@MainActor
final class CustomMarkerManager {
    private var markers: [String: NMFMarker] = [:]
    
    func updateMarkers(
        items: [CustomMarkerItem],
        isVisible: Bool,
        on mapView: NMFMapView
    ) {
        // 마커 업데이트 로직
        // 1. 기존 마커 제거
        // 2. 새 마커 생성
        // 3. 지도에 추가
    }
}
```

#### Step 3: MapFacade에 통합

```swift
// Facade/MapFacade.swift

private let customMarkerManager: CustomMarkerManager

init(
    infrastructureManager: InfrastructureMarkerManager,
    caseLocationMarkerManager: CaseLocationMarkerManager
) {
    // ...
    self.customMarkerManager = CustomMarkerManager()
}

func update(
    mapView: NMFMapView,
    // ... 기존 파라미터들
    layerData: LayerData,
    // ...
) {
    // ... 기존 로직
    
    customMarkerManager.updateMarkers(
        items: layerData.customMarkers,
        isVisible: layerData.isCustomMarkerVisible,
        on: mapView
    )
}

struct LayerData {
    // ... 기존 필드들
    let customMarkers: [CustomMarkerItem]
    let isCustomMarkerVisible: Bool
}
```

#### Step 4: NaverMapView에 노출

```swift
// NaverMapView.swift

struct NaverMapView: UIViewRepresentable {
    var customMarkers: [CustomMarkerItem] = []
    var isCustomMarkerVisible: Bool = false

    func updateUIView(_ uiView: NMFMapView, context: Context) {
        let layerData = MapFacade.LayerData(
            // ... 기존 필드들
            customMarkers: customMarkers,
            isCustomMarkerVisible: isCustomMarkerVisible
        )
        
        context.coordinator.facade.update(
            mapView: uiView,
            // ... 기타 파라미터들
            layerData: layerData,
            // ...
        )
    }
}
```

## 중요 사항

### 메모리 관리

클로저에서 `self`를 캡처할 때는 항상 `[weak self]`를 사용하고, `mapView`는 `weak var`로 선언합니다. `parent` (struct)는 `weak`로 캡처할 수 없으므로 `[weak self]`로 `self`를 캡처하고 `self.parent`로 접근합니다.

```swift
// 올바른 예
facade.configureCallbacks(
    onEvent: { [weak self] value in
        self?.parent.onEvent?(value)
    }
)

// 잘못된 예 (컴파일 에러)
facade.configureCallbacks(
    onEvent: { [weak parent] value in
        parent?.onEvent?(value)  // struct는 weak로 캡처 불가
    }
)
```

### 상수 관리

모든 하드코딩된 값은 `MapConstants`에 추가합니다. 위치: `Base/NMConstants.swift`

### 네이밍 컨벤션

- **Controller**: `MapXXXController`
- **Handler**: `MapXXXHandler`
- **Service**: `MapXXXService`
- **Updater**: `MapXXXUpdater`
- **Manager**: `XXXMarkerManager` 또는 `XXXLayerManager`

### 접근 제어

컴포넌트는 `internal` 또는 `private`로 유지하고, MapFacade를 통해서만 접근 가능하도록 설계합니다. NaverMapView는 `public` 인터페이스만 노출합니다.

## 요약

새로운 맵 기능을 추가하는 과정은 다음 5단계로 구성됩니다:

1. **기능 타입 판단**: Controller/Handler/Service/Updater/Manager 중 선택
2. **컴포넌트에 기능 추가**: 기존 컴포넌트 확장 또는 새로 생성
3. **MapFacade에 통합**: 프로퍼티 추가, 메서드 추가, update/configureCallbacks 통합
4. **NaverMapView에 노출**: 프로퍼티 추가, updateUIView/Delegate 처리
5. **MapView/MapFeature에서 사용**: State/Action 추가, reduce에서 처리

