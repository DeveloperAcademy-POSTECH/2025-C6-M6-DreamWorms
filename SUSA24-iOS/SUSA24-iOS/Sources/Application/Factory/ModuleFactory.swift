//
//  ModuleFactory.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

protocol ModuleFactoryProtocol {
    func makeCameraView() -> CameraView
    func makeCaseAddView() -> CaseAddView
    func makeCaseListView() -> CaseListView
    func makeDashboardView() -> DashboardView
    func makeMainTabView() -> MainTabView
    func makeMapView() -> MapView
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
    
    func makeCaseAddView() -> CaseAddView {
        let view = CaseAddView()
        return view
    }
    
    func makeCaseListView() -> CaseListView {
        let view = CaseListView()
        return view
    }
    
    func makeDashboardView() -> DashboardView {
        let view = DashboardView()
        return view
    }
    
    func makeMainTabView() -> MainTabView {
        let view = MainTabView()
        return view
    }
    
    func makeMapView() -> MapView {
        let view = MapView()
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
