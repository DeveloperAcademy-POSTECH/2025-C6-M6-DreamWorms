//
//  KakaoSearchAPIService.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

/// 카카오 검색 API 서비스
final class KakaoSearchAPIService: SearchAPIService {
    // MARK: - Properties
    
    /// 카카오 API 전용 디코더 (snake_case 변환)
    private let kakaoDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Public Methods
    
    /// 좌표로 주소 정보를 조회합니다.
    /// - Parameter requestDTO: 좌표 조회 요청 DTO
    /// - Returns: 좌표에 해당하는 주소 정보 응답
    /// - Throws: `KakaoSearchError`
    func fetchLocationFromCoord(_ requestDTO: KakaoCoordToLocationRequestDTO) async throws -> KakaoCoordToLocationResponseDTO {
        let endpoint = KakaoEndpoint.coordToLocation(requestDTO)
        
        do {
            let response: KakaoCoordToLocationResponseDTO = try await NetworkClient.shared.request(
                endpoint: endpoint,
                decoder: kakaoDecoder
            )
            
            guard response.meta.totalCount > 0 else { throw KakaoSearchError.noResults }
            return response
            
        } catch let error as KakaoSearchError {
            throw error
        } catch let error as NetworkError {
            throw KakaoSearchError.networkError(error)
        } catch {
            throw KakaoSearchError.unknown(error)
        }
    }
    
    /// 키워드로 장소를 검색합니다.
    /// - Parameter requestDTO: 키워드 검색 요청 DTO
    /// - Returns: 키워드 검색 결과 응답
    /// - Throws: `KakaoSearchError`
    func fetchPlaceFromKeyword(_ requestDTO: KakaoKeywordToPlaceRequestDTO) async throws -> KakaoKeywordToPlaceResponseDTO {
        let endpoint = KakaoEndpoint.keywordToPlace(requestDTO)
        
        do {
            let response: KakaoKeywordToPlaceResponseDTO = try await NetworkClient.shared.request(
                endpoint: endpoint,
                decoder: kakaoDecoder
            )
            
            guard response.meta.totalCount > 0 else { throw KakaoSearchError.noResults }
            return response
            
        } catch let error as KakaoSearchError {
            throw error
        } catch let error as NetworkError {
            throw KakaoSearchError.networkError(error)
        } catch {
            throw KakaoSearchError.unknown(error)
        }
    }
}
