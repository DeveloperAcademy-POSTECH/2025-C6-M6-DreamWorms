//
//  ModuleFactory.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import CoreData
import SwiftUI

protocol ModuleFactoryProtocol {
    func makeCameraView(caseID: UUID) -> CameraView
    func makeCaseAddView(caseID: UUID?, context: NSManagedObjectContext) -> CaseAddView
    func makeCaseListView(context: NSManagedObjectContext) -> CaseListView
    func makeDashboardView(caseID: UUID, context: NSManagedObjectContext) -> DashboardView
    func makeLocationOverviewView(
        caseID: UUID,
        baseAddress: String,
        initialCoordinate: MapCoordinate,
        context: NSManagedObjectContext
    ) -> LocationOverviewView
    func makeMainTabView(caseID: UUID, context: NSManagedObjectContext) -> MainTabView<
        MapView,
        TrackingView,
        DashboardView
    >
    func makeMapView(caseID: UUID, context: NSManagedObjectContext) -> MapView
    func makeOnePageView(caseID: UUID, context: NSManagedObjectContext) -> OnePageView
    func makeSearchView() -> SearchView
    func makeSelectLocationView() -> SelectLocationView
    func makeSettingView() -> SettingView
    func makeTimeLineView(caseInfo: Case?, locations: [Location]) -> TimeLineView
    func makePhotoDetailsView(photos: [CapturedPhoto], camera: CameraModel) -> PhotoDetailsView
    func makeScanLoadView(caseID: UUID, photos: [CapturedPhoto]) -> ScanLoadView
    func makeScanListView(caseID: UUID, scanResults: [ScanResult], context: NSManagedObjectContext) -> ScanListView
    func makeTrackingView(caseID: UUID, context: NSManagedObjectContext) -> TrackingView
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    private lazy var mapDispatcher = MapDispatcher()
    private lazy var searchService = KakaoSearchAPIService()
    private lazy var cctvService = VWorldCCTVAPIService()
    private lazy var infrastructureMarkerManager = InfrastructureMarkerManager()
    private lazy var caseLocationMarkerManager = CaseLocationMarkerManager()
    private lazy var camera = CameraModel()
    
    func makeCameraView(caseID: UUID) -> CameraView {
        let store = DWStore(
            initialState: CameraFeature.State(caseID: caseID, previewSource: camera.previewSource),
            reducer: CameraFeature(camera: camera)
        )
        let view = CameraView(store: store, camera: camera)
        return view
    }
    
    func makeCaseAddView(caseID: UUID?, context: NSManagedObjectContext) -> CaseAddView {
        let repository = CaseRepository(context: context)
        let store = DWStore(
            initialState: CaseAddFeature.State(editingCaseId: caseID),
            reducer: CaseAddFeature(repository: repository)
        )
        let view = CaseAddView(store: store)
        return view
    }
    
    func makeCaseListView(context: NSManagedObjectContext) -> CaseListView {
        let repository = CaseRepository(context: context)
        let store = DWStore(
            initialState: CaseListFeature.State(),
            reducer: CaseListFeature(repository: repository)
        )
        let view = CaseListView(store: store)
        return view
    }
    
    func makeDashboardView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> DashboardView {
        let repository = LocationRepository(context: context)
        let service = DashboardAnalysisService()
        let store = DWStore(
            initialState: DashboardFeature.State(),
            reducer: DashboardFeature(
                repository: repository,
                analysisService: service
            )
        )
        let view = DashboardView(store: store, currentCaseID: caseID)
        return view
    }
    
    func makeLocationOverviewView(
        caseID: UUID,
        baseAddress: String,
        initialCoordinate: MapCoordinate,
        context: NSManagedObjectContext
    ) -> LocationOverviewView {
        let repository = LocationRepository(context: context)
        let store = DWStore(
            initialState: LocationOverviewFeature.State(),
            reducer: LocationOverviewFeature(repository: repository)
        )
        let view = LocationOverviewView(
            store: store,
            caseID: caseID,
            baseAddress: baseAddress,
            initialCoordinate: initialCoordinate
        )
        return view
    }

    func makeMainTabView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> MainTabView<MapView, TrackingView, DashboardView> {
        let caseRepository = CaseRepository(context: context)
        let locationRepository = LocationRepository(context: context)

        let store = DWStore(
            initialState: MainTabFeature.State(selectedCurrentCaseId: caseID),
            reducer: MainTabFeature(
                caseRepository: caseRepository,
                locationRepository: locationRepository
            )
        )
        
        // MapView와 store를 함께 생성 (Timeline과 동일한 패턴)
        let mapStore = DWStore(
            initialState: MapFeature.State(caseId: caseID),
            reducer: MapFeature(
                repository: LocationRepository(context: context),
                searchService: searchService,
                cctvService: cctvService,
                dispatcher: mapDispatcher
            )
        )
        let mapView = MapView(
            store: mapStore,
            dispatcher: mapDispatcher,
            infrastructureManager: infrastructureMarkerManager,
            caseLocationMarkerManager: caseLocationMarkerManager
        )
        let trackingView = makeTrackingView(caseID: caseID, context: context)
        let dashboardView = makeDashboardView(caseID: caseID, context: context)
        
        // 여기서 미리 생성
        let timeLineStore = DWStore(
            initialState: TimeLineFeature.State(
                caseInfo: nil,
                locations: []
            ),
            reducer: TimeLineFeature(dispatcher: mapDispatcher)
        )

        let view = MainTabView(
            store: store,
            timeLineStore: timeLineStore,
            mapStore: mapStore,
            dispatcher: mapDispatcher,
            mapView: { mapView },
            trackingView: { trackingView },
            dashboardView: { dashboardView }
        )
        return view
    }
    
    func makeMapView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> MapView {
        let repository = LocationRepository(context: context)
        let store = DWStore(
            initialState: MapFeature.State(caseId: caseID),
            reducer: MapFeature(
                repository: repository,
                searchService: searchService,
                cctvService: cctvService,
                dispatcher: mapDispatcher
            )
        )
        let view = MapView(
            store: store,
            dispatcher: mapDispatcher,
            infrastructureManager: infrastructureMarkerManager,
            caseLocationMarkerManager: caseLocationMarkerManager
        )
        return view
    }
    
    func makeOnePageView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> OnePageView {
        let caseRepository = CaseRepository(context: context)
        let locationRepository = LocationRepository(context: context)
        let store = DWStore(
            initialState: OnePageFeature.State(),
            reducer: OnePageFeature(
                caseRepository: caseRepository,
                locationRepository: locationRepository
            )
        )
        let view = OnePageView(store: store, currentCaseID: caseID)
        return view
    }
    
    func makeSearchView() -> SearchView {
        let store = DWStore(
            initialState: SearchFeature.State(),
            reducer: SearchFeature(
                searchService: searchService,
                dispatcher: mapDispatcher
            )
        )
        let view = SearchView(store: store)
        return view
    }
    
    func makeSelectLocationView() -> SelectLocationView {
        let view = SelectLocationView()
        return view
    }
    
    func makeSettingView() -> SettingView {
        let view = SettingView()
        return view
    }
    
    func makeTimeLineView(
        caseInfo: Case?,
        locations: [Location]
    ) -> TimeLineView {
        let store = DWStore(
            initialState: TimeLineFeature.State(
                caseInfo: caseInfo,
                locations: locations
            ),
            reducer: TimeLineFeature(dispatcher: mapDispatcher)
        )
        
        let view = TimeLineView(store: store)
        return view
    }
    
    func makePhotoDetailsView(
        photos: [CapturedPhoto],
        camera: CameraModel
    ) -> PhotoDetailsView {
        let store = DWStore(
            initialState: PhotoDetailsFeature.State(
                photos: photos
            ),
            reducer: PhotoDetailsFeature(camera: camera)
        )
        return PhotoDetailsView(store: store)
    }
    
    func makeScanLoadView(
        caseID: UUID,
        photos: [CapturedPhoto]
    ) -> ScanLoadView {
        let batchAnalyzer = BatchAddressAnalyzer()
        let feature = ScanLoadFeature(batchAnalyzer: batchAnalyzer)
        let store = DWStore(
            initialState: ScanLoadFeature.State(),
            reducer: feature
        )
        return ScanLoadView(
            caseID: caseID,
            photos: photos,
            camera: camera,
            store: store
        )
    }
    
    func makeScanListView(
        caseID: UUID,
        scanResults: [ScanResult],
        context: NSManagedObjectContext
    ) -> ScanListView {
        let repository = LocationRepository(context: context)
        let feature = ScanListFeature(repository: repository)
        let store = DWStore(
            initialState: ScanListFeature.State(scanResults: scanResults),
            reducer: feature
        )
        return ScanListView(caseID: caseID, store: store)
    }
    
    func makeTrackingView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> TrackingView {
        let repository = LocationRepository(context: context)
        let feature = TrackingFeature(repository: repository)
        let store = DWStore(
            initialState: TrackingFeature.State(),
            reducer: feature
        )
        let view = TrackingView(timeLineStore: store, caseID: caseID)
        return view
    }
}
