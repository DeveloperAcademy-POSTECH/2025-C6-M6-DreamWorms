//
//  Persistence.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "SUSA24_iOS")
        
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if inMemory || isPreview {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // 자동 마이그레이션 옵션
        let desc = container.persistentStoreDescriptions.first
        desc?.shouldMigrateStoreAutomatically = true
        desc?.shouldInferMappingModelAutomatically = true

        container.loadPersistentStores { _, error in
            if let error {
                #if DEBUG
                    assertionFailure("CoreData load error: \(error)")
                #else
                    print("CoreData load error: \(error)")
                #endif
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
