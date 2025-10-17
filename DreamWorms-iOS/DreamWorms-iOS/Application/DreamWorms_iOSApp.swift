//
//  DreamWorms_iOSApp.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/15/25.
//

import SwiftUI

@main
struct DreamWorms_iOSApp: App {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            AppRootView(moduleFactory: ModuleFactory.shared)
                .environmentObject(coordinator)
        }
    }
}
