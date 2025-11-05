//
//  ModuleFactory.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import CoreData
import SwiftUI

protocol ModuleFactoryProtocol {
    func makeCameraView() -> CameraView
    func makeCaseAddView(context: NSManagedObjectContext) -> CaseAddView
    func makeCaseListView(context: NSManagedObjectContext) -> CaseListView
    func makeDashboardView() -> DashboardView
    func makeMainTabView(caseId: UUID, context: NSManagedObjectContext) -> MainTabView
    func makeMapView(context: NSManagedObjectContext) -> MapView
    func makeOnePageView() -> OnePageView
    func makeSearchView() -> SearchView
    func makeSelectLocationView() -> SelectLocationView
    func makeSettingView() -> SettingView
    func makeTimeLineView() -> TimeLineView
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    
    func makeCameraView() -> CameraView {
        let view = CameraView()
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
    
    func makeDashboardView() -> DashboardView {
        let view = DashboardView()
        return view
    }
    
    func makeMainTabView(caseId: UUID, context: NSManagedObjectContext) -> MainTabView {
        
        let locationRepository = LocationRepository(context: context)
        let caseRepository = CaseRepository(context: context)
        
        let mainTabStore = DWStore(
            initialState: MainTabFeature.State(selectedCurrentCaseId: caseId),
            reducer: MainTabFeature(caseRepository: caseRepository))
        
        let mapStore = DWStore(
            initialState: MapFeature.State(caseId: caseId),
            reducer: MapFeature(repository: locationRepository))
        
//        let timelineStore = DWStore(
//            initialState: <#T##_#>,
//            reducer: DWReducer)
        
        return MainTabView(
            store: mainTabStore,
            mapStore: mapStore,
//            timelineStore: timelineStore
        )
    }
    
    func makeMapView(context: NSManagedObjectContext) -> MapView {
        let repository = LocationRepository(context: context)
        let store = DWStore(
            initialState: MapFeature.State(),
            reducer: MapFeature(repository: repository))
        let view = MapView(store: store)
        return view
    }
    
    func makeOnePageView() -> OnePageView {
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
