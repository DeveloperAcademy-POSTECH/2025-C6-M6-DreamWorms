//
//  CaseLocation.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/18/25.
//

import Foundation
import SwiftData

@Model
final class CaseLocation {
    @Attribute(.unique) var id: UUID
    var pinType: PinType
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var receivedAt: Date
    
    var parentCase: Case?
    
    init(
        id: UUID = UUID(),
        pinType: PinType,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        receivedAt: Date = Date()
    ) {
        self.id = id
        self.pinType = pinType
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.receivedAt = receivedAt
    }
}

enum PinType: String, Codable {
    case telecom
    case custom
}
