//
//  CCTVAPIService.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

protocol CCTVAPIService: Sendable {
    func fetchCCTVByBox(_ requestDTO: VWorldBoxRequestDTO) async throws -> VWorldCCTVResponseDTO
    func fetchCCTVByPolygon(_ requestDTO: VWorldPolygonRequestDTO) async throws -> VWorldCCTVResponseDTO
}
