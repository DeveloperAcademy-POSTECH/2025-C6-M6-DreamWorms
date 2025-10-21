//
//  AppRouteView.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject
    private var coordinator: AppCoordinator
    private let moduleFactory: ModuleFactoryProtocol
    
    init(
        moduleFactory: ModuleFactoryProtocol
    ) {
        self.moduleFactory = moduleFactory
    }
    
    var body: some View {
        NavigationStack(
            path: Binding(
                get: { coordinator.path },
                set: { coordinator.path = $0 }
            )
        ) {
            moduleFactory.makeCaseListView()
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .caseList:
                        moduleFactory.makeCaseListView()
                    case .caseAdd:
                        moduleFactory.makeCaseAddView()
                    case let .map(selectedCase):
                        moduleFactory.makeMapView(selectedCase: selectedCase)
                    case .search:
                        moduleFactory.makeSearchView()
                    case .reportRecognition:
                        if #available(iOS 18.0, *) {
                            moduleFactory.makeReportRecognitionView()
                        } else {
                            ContentView()
                        }
                    }
                }
        }
    }
}
