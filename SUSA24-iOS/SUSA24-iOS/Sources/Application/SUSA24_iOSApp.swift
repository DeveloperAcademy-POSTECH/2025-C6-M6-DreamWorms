//
//  SUSA24_iOSApp.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI
import CoreData

@main
struct SUSA24_iOSApp: App {
    @State private var coordinator = AppCoordinator()
    @State private var tabBarVisibility = TabBarVisibility()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView(moduleFactory: ModuleFactory.shared)
                .environment(coordinator)
                .environment(tabBarVisibility)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
