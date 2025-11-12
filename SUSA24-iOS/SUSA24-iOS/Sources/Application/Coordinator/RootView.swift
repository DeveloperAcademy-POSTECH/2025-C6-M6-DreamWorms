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
    
    @Environment(TabBarVisibility.self)
    private var tabBarVisibility
    
    @Environment(\.managedObjectContext)
    private var context
    
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
            moduleFactory.makeCaseListView(context: context)
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    Group {
                        switch route {
                        case let .cameraScene(caseID):
                            moduleFactory.makeCameraView(caseID: caseID)
                        case .caseAddScene:
                            moduleFactory.makeCaseAddView(context: context)
                        case .caseListScene:
                            moduleFactory.makeCaseListView(context: context)
                        case let .dashboardScene(caseID):
                            moduleFactory.makeDashboardView(caseID: caseID, context: context)
                        case let .mainTabScene(caseID):
                            moduleFactory.makeMainTabView(caseID: caseID, context: context)
                        case let .mapScene(caseID):
                            moduleFactory.makeMapView(caseID: caseID, context: context)
                        case let .onePageScene(caseID):
                            moduleFactory.makeOnePageView(caseID: caseID, context: context)
                        case .searchScene:
                            moduleFactory.makeSearchView()
                        case .selectLocationScene:
                            moduleFactory.makeSelectLocationView()
                        case .settingScene:
                            moduleFactory.makeSettingView()
                            //                    case .timeLineScene:
                            //                        moduleFactory.makeTimeLineView()
                        case let .photoDetailsScene(photos, camera):
                            moduleFactory.makePhotoDetailsView(photos: photos, camera: camera)
                        case .scanLoadScene:
                            moduleFactory.makeScanLoadView()
                        }
                    }
                    .onChange(of: coordinator.currentRoute) {
                        guard let route = coordinator.currentRoute else {
                            tabBarVisibility.hide()
                            return
                        }

                        if route.useTabBar {
                            tabBarVisibility.show()
                        } else {
                            tabBarVisibility.hide()
                        }
                    }
                }
        }
    }
}
