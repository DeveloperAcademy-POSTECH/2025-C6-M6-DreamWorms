//
//  Case.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import Foundation

struct Case: Identifiable, Equatable, Sendable {
    var id: UUID
    var number: String
    var name: String
    var crime: String
    var suspect: String
    var suspectProfileImage: String?
}
