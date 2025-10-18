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
    func makeMapView() -> MapView
    func makeSearchView() -> SearchView
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
    
    func makeMapView() -> MapView {
        let view = MapView()
        return view
    }
    
    func makeSearchView() -> SearchView {
        let view = SearchView()
        return view
    }
}
