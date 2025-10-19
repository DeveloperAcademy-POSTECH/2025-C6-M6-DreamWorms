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
