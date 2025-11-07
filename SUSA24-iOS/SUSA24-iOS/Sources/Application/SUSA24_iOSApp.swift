//
//  SUSA24_iOSApp.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import CoreData
import SwiftUI

@main
struct SUSA24_iOSApp: App {
    @State private var coordinator = AppCoordinator()

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(moduleFactory: ModuleFactory.shared)
                .environment(coordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
