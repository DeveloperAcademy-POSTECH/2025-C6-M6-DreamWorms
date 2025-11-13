//
//  CellStationDTO.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/12/25.
//

import Foundation

/// 기지국 JSON 파싱용 DTO
struct CellStationDTO: Decodable, Sendable {
    let permitNumber: Int
    let location: String
    let purpose: String
    let latitudeDecimal: Double
    let longitudeDecimal: Double
    
    enum CodingKeys: String, CodingKey {
        case permitNumber = "허가번호"
        case location = "설(상)치 장소"
        case purpose = "용도"
        case latitudeDecimal = "위도(십진)"
        case longitudeDecimal = "경도(십진)"
    }
}

/// JSON Root 구조
struct CellStationRoot: Decodable, Sendable {
    let sheet1: [CellStationDTO]
    
    enum CodingKeys: String, CodingKey {
        case sheet1 = "Sheet1"
    }
}
