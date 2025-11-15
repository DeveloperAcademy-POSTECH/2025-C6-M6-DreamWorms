//
//  StayAddress.swift
//  SUSA24-iOS
//
//  Created by mini on 11/5/25.
//

import Foundation

struct StayAddress: Identifiable, Equatable, Sendable {
    let id = UUID()
    let address: String
    let totalMinutes: Int
    let latitude: Double
    let longitude: Double
}
