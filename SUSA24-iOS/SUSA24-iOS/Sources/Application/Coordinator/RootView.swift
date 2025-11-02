//
//  RootView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct RootView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    private let moduleFactory: ModuleFactoryProtocol
    
    public init(
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
                    case .cameraScene:
                        moduleFactory.makeCameraView()
                    case .caseAddScene:
                        moduleFactory.makeCaseAddView()
                    case .caseListScene:
                        moduleFactory.makeCaseListView()
                    case .dashboardScene:
                        moduleFactory.makeDashboardView()
                    case .mainTabScene:
                        moduleFactory.makeMainTabView()
                    case .mapScene:
                        moduleFactory.makeMapView()
                    case .onePageScene:
                        moduleFactory.makeOnePageView()
                    case .searchScene:
                        moduleFactory.makeSearchView()
                    case .selectLocationScene:
                        moduleFactory.makeSelectLocationView()
                    case .settingScene:
                        moduleFactory.makeSettingView()
                    case .timeLineScene:
                        moduleFactory.makeTimeLineView()
                    }
                }
        }
    }
}



