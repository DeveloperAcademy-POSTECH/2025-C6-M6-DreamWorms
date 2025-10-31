//
//  GeocodeResponseDTO.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import Foundation

struct GeocodeResponseDTO: Decodable, Sendable {
    let status: String
    let addresses: [Address]
    let errorMessage: String
}

struct Address: Decodable, Sendable {
    let roadAddress: String
    let jibunAddress: String
    let x: String
    let y: String
    
    var latitude: Double? { Double(y) }
    var longitude: Double? { Double(x) }
    
    var fullAddress: String {
        roadAddress.isEmpty ? jibunAddress : roadAddress
    }
}
