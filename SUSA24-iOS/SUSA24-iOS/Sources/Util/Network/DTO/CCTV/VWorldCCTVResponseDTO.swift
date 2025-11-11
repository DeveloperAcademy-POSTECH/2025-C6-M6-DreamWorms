//
//  VWorldCCTVResponseDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

struct VWorldCCTVResponseDTO: Decodable, Sendable {
    let features: [VWorldFeature]
    
    enum CodingKeys: String, CodingKey {
        case response, result, featureCollection, features
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let response = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        let result = try response.nestedContainer(keyedBy: CodingKeys.self, forKey: .result)
        let featureCollection = try result.nestedContainer(keyedBy: CodingKeys.self, forKey: .featureCollection)
        self.features = try featureCollection.decode([VWorldFeature].self, forKey: .features)
    }
}

struct VWorldFeature: Decodable, Sendable {
    let geometry: VWorldGeometry
    let properties: VWorldProperties
    let id: String
}

struct VWorldGeometry: Decodable, Sendable {
    let coordinates: [Double]
}

struct VWorldProperties: Decodable, Sendable {
    let locate: String
    let cctvname: String
}
