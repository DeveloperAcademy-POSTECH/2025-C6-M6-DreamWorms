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
    func makeCaseAddView(context: NSManagedObjectContext) -> CaseAddView
    func makeCaseListView(context: NSManagedObjectContext) -> CaseListView
    func makeDashboardView(caseID: UUID, context: NSManagedObjectContext) -> DashboardView
    func makeMainTabView(caseID: UUID, context: NSManagedObjectContext) -> MainTabView<
        MapView,
        DashboardView,
        OnePageView
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
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    private lazy var mapDispatcher = MapDispatcher()
    private lazy var searchService = KakaoSearchAPIService()
    private lazy var cctvService = VWorldCCTVAPIService()
    
    func makeCameraView(caseID: UUID) -> CameraView {
        // cameraModel 주입
        let camera = CameraModel()
        let store = DWStore(
            initialState: CameraFeature.State(caseID: caseID, previewSource: camera.previewSource),
            reducer: CameraFeature(camera: camera)
        )
        let view = CameraView(store: store, camera: camera)
        return view
    }
    
    func makeCaseAddView(context: NSManagedObjectContext) -> CaseAddView {
        let repository = CaseRepository(context: context)
        let store = DWStore(
            initialState: CaseAddFeature.State(),
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
        let store = DWStore(
            initialState: DashboardFeature.State(),
            reducer: DashboardFeature(repository: repository)
        )
        let view = DashboardView(store: store, currentCaseID: caseID)
        return view
    }
    
    func makeMainTabView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> MainTabView<MapView, DashboardView, OnePageView> {
        let caseRepository = CaseRepository(context: context)
        
        let store = DWStore(
            initialState: MainTabFeature.State(selectedCurrentCaseId: caseID),
            reducer: MainTabFeature(caseRepository: caseRepository)
        )
        
        let mapView = makeMapView(caseID: caseID, context: context)
        let dashboardView = makeDashboardView(caseID: caseID, context: context)
        let onePageView = makeOnePageView(caseID: caseID, context: context)
        
        // 여기서 미리 생성
        let timeLineStore = DWStore(
            initialState: TimeLineFeature.State(
                caseInfo: nil,
                locations: []
            ),
            reducer: TimeLineFeature()
        )
        
        let view = MainTabView(
            store: store,
            timeLineStore: timeLineStore,
            mapView: { mapView },
            dashboardView: { dashboardView },
            onePageView: { onePageView }
        )
        return view
    }
    
    func makeMapView(
        caseID _: UUID,
        context: NSManagedObjectContext
    ) -> MapView {
        let repository = LocationRepository(context: context)
        let store = DWStore(
            initialState: MapFeature.State(),
            reducer: MapFeature(
                repository: repository,
                searchService: searchService,
                cctvService: cctvService,
                dispatcher: mapDispatcher
            )
        )
        let view = MapView(store: store, dispatcher: mapDispatcher)
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
            reducer: TimeLineFeature()
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
}
