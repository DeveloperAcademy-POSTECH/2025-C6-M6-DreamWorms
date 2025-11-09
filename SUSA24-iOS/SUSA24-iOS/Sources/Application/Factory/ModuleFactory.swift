//
//  ModuleFactory.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import CoreData
import SwiftUI

protocol ModuleFactoryProtocol {
    func makeCameraView() -> CameraSampleView
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
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    
    func makeCameraView() -> CameraSampleView {
        let view = CameraSampleView()
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
            reducer: MapFeature(repository: repository)
        )
        let view = MapView(store: store)
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
}
