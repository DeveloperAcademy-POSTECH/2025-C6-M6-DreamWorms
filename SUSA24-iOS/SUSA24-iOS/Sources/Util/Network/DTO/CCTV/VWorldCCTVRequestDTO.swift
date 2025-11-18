//
//  VWorldCCTVRequestDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

struct VWorldBoxRequestDTO: Sendable, Encodable {
    let minLng: Double
    let minLat: Double
    let maxLng: Double
    let maxLat: Double
    let size: Int
    let page: Int
}

struct VWorldPolygonRequestDTO: Sendable, Encodable {
    let coordinates: [MapCoordinate]
    let size: Int
    let page: Int
}
