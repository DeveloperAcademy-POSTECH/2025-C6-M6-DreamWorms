//
//  CCTVItem.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import Foundation

struct CCTVItem: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}
