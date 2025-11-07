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
    func makeMainTabView(caseID: UUID, context: NSManagedObjectContext) -> MainTabView<MapView, DashboardView, OnePageView>
    func makeMapView(caseID: UUID, context: NSManagedObjectContext) -> MapView
    func makeOnePageView(caseID: UUID, context: NSManagedObjectContext) -> OnePageView
    func makeSearchView() -> SearchView
    func makeSelectLocationView() -> SelectLocationView
    func makeSettingView() -> SettingView
    func makeTimeLineView() -> TimeLineView
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    
    func makeCameraView(caseID: UUID) -> CameraView {
        // cameraModel 주입
        let cameraManager = CameraModel()
        let store = DWStore(
            initialState: CameraFeature.State(previewSource: cameraManager.previewSource),
            reducer: CameraFeature(cameraManager: cameraManager))
        let view = CameraView(store: store, cameraManager: cameraManager)
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
            reducer: CaseListFeature(repository: repository))
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
        
        let view = MainTabView(
            store: store,
            mapView: {  mapView },
            dashboardView: { dashboardView },
            onePageView: { onePageView }
        )
        return view
    }
    
    func makeMapView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> MapView {
        let repository = LocationRepository(context: context)
        let store = DWStore(
            initialState: MapFeature.State(),
            reducer: MapFeature(repository: repository))
        let view = MapView(store: store)
        return view
    }
    
    func makeOnePageView(
        caseID: UUID,
        context: NSManagedObjectContext
    ) -> OnePageView {
        let view = OnePageView()
        return view
    }
    
    func makeSearchView() -> SearchView {
        let view = SearchView()
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
    
    func makeTimeLineView() -> TimeLineView {
        let view = TimeLineView()
        return view
    }
}
