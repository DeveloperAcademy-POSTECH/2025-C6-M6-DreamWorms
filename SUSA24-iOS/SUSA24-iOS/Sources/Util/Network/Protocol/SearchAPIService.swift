//
//  SearchAPIService.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

/// 검색 API 서비스 프로토콜
protocol SearchAPIService: Sendable {
    func fetchLocationFromCoord(_ requestDTO: KakaoCoordToLocationRequestDTO) async throws -> KakaoCoordToLocationResponseDTO
    func fetchPlaceFromKeyword(_ requestDTO: KakaoKeywordToPlaceRequestDTO) async throws -> KakaoKeywordToPlaceResponseDTO
}
