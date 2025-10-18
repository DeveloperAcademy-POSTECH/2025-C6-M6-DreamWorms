//
//  Case.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/18/25.
//

import Foundation
import SwiftData

@Model
final class Case {
    @Attribute(.unique) var id: UUID
    var name: String
    var number: String
    var suspectName: String
    
    @Relationship(deleteRule: .cascade, inverse: \CaseLocation.parentCase)
    var locations: [CaseLocation] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        number: String,
        suspectName: String
    ) {
        self.id = id
        self.name = name
        self.number = number
        self.suspectName = suspectName
    }
}

// NOTE: 삭제 예정
extension Case {
    func setAsCurrentCase() {
        UserDefaults.standard.set(id.uuidString, forKey: "activeCase")
    }
}
