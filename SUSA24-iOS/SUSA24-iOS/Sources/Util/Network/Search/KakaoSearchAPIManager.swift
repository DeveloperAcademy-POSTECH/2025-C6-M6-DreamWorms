//
//  KakaoSearchAPIManager.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Alamofire
import Foundation

/// 카카오 검색 API 매니저
final class KakaoSearchAPIManager {
    static let shared = KakaoSearchAPIManager()
    private init() {}
    
    private let session: Session = {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 10
        return Session(configuration: config)
    }()
    
    /// 카카오 API 공통 디코더
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    // MARK: - Private Helper Methods
    
    /// 공통 네트워크 요청 처리 메서드
    /// - Parameters:
    ///   - url: 완전한 요청 URL (쿼리 파라미터 포함)
    ///   - responseType: 응답 타입
    /// - Returns: 디코딩된 응답 객체
    /// - Throws: `KakaoSearchError`
    private func request<T: Decodable>(
        url: String,
        responseType: T.Type
    ) async throws -> T {
        do {
            let requestData = try await session
                .request(url, method: .get, headers: NetworkHeader.kakaoHeaders)
                .serializingData()
                .value
            
            let response = try decoder.decode(T.self, from: requestData)
            if let metaResponse = response as? any KakaoResponseMeta {
                guard metaResponse.totalCount > 0 else { throw KakaoSearchError.noResults }
            }
            return response
        } catch let error as DecodingError {
            throw KakaoSearchError.decodingFailed(error)
        } catch let error as AFError {
            throw KakaoSearchError.requestFailed(error)
        } catch let error as KakaoSearchError {
            throw error
        } catch {
            throw KakaoSearchError.unknown(error)
        }
    }
}

// MARK: - API Methods Extension

extension KakaoSearchAPIManager {
    /// 좌표로 주소 정보를 조회합니다.
    /// - Parameter requestDTO: 좌표 조회 요청 DTO
    /// - Returns: 좌표에 해당하는 주소 정보 응답
    /// - Throws: `KakaoSearchError`
    func fetchLocationFromCoord(_ requestDTO: KakaoCoordToLocationRequestDTO) async throws -> KakaoCoordToLocationResponseDTO {
        let fullURL = try URLBuilder.build(
            baseURL: URLConstant.kakaoCoordToLocationURL,
            parameters: [
                "x": requestDTO.x,
                "y": requestDTO.y,
                "inputCoord": requestDTO.inputCoord
            ]
        )
        return try await request(url: fullURL, responseType: KakaoCoordToLocationResponseDTO.self)
    }
    
    /// 키워드로 장소를 검색합니다.
    /// - Parameter requestDTO: 키워드 검색 요청 DTO
    /// - Returns: 키워드 검색 결과 응답
    /// - Throws: `KakaoSearchError`
    func fetchPlaceFromKeyword(_ requestDTO: KakaoKeywordToPlaceRequestDTO) async throws -> KakaoKeywordToPlaceResponseDTO {
        let fullURL = try URLBuilder.build(
            baseURL: URLConstant.kakaoKeywordToPlaceURL,
            parameters: [
                "query": requestDTO.query,
                "x": requestDTO.x,
                "y": requestDTO.y,
                "radius": requestDTO.radius,
                "page": requestDTO.page,
                "size": requestDTO.size
            ]
        )
        return try await request(url: fullURL, responseType: KakaoKeywordToPlaceResponseDTO.self)
    }
}

// MARK: - Helper Protocol

/// 카카오 API 응답의 메타 정보를 나타내는 프로토콜
private protocol KakaoResponseMeta {
    var totalCount: Int { get }
}

extension KakaoCoordToLocationResponseDTO: KakaoResponseMeta {
    var totalCount: Int { meta.totalCount }
}

extension KakaoKeywordToPlaceResponseDTO: KakaoResponseMeta {
    var totalCount: Int { meta.totalCount }
}
