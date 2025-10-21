//
//  ModuleFactory.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI

protocol ModuleFactoryProtocol {
    func makeCaseListView() -> CaseListView
    func makeCaseAddView() -> CaseAddView
    func makeMapView(selectedCase: Case) -> MapView
    func makeSearchView() -> SearchView
    
    @available(iOS 18.0, *)
    func makeReportRecognitionView() -> ReportRecognitionView
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    
    func makeCaseListView() -> CaseListView {
        let view = CaseListView()
        return view
    }
    
    func makeCaseAddView() -> CaseAddView {
        let view = CaseAddView()
        return view
    }
    
    func makeMapView(selectedCase: Case) -> MapView {
        let view = MapView(selectedCase: selectedCase)
        return view
    }
    
    func makeSearchView() -> SearchView {
        let view = SearchView()
        return view
    }
    
    @available(iOS 18.0, *)
    func makeReportRecognitionView() -> ReportRecognitionView {
        let view = ReportRecognitionView()
        return view
    }
}
