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
    /// - Parameters:
    ///   - x: 경도(Longitude)
    ///   - y: 위도(Latitude)
    ///   - inputCoord: 입력 좌표계 (기본값: WGS84)
    /// - Returns: 좌표에 해당하는 주소 정보 응답
    /// - Throws: `KakaoSearchError`
    func fetchLocationFromCoord(x: String, y: String, inputCoord: String? = nil) async throws -> KakaoCoordToLocationResponseDTO {
        let fullURL = try URLBuilder.build(
            baseURL: URLConstant.kakaoCoordToLocationURL,
            parameters: [
                "x": x,
                "y": y,
                "inputCoord": inputCoord
            ]
        )
        return try await request(url: fullURL, responseType: KakaoCoordToLocationResponseDTO.self)
    }
    
    /// 키워드로 장소를 검색합니다.
    /// - Parameters:
    ///   - query: 검색을 원하는 질의어
    ///   - x: 중심 좌표의 경도(longitude)
    ///   - y: 중심 좌표의 위도(latitude)
    ///   - radius: 중심 좌표부터의 반경거리(단위: 미터). 최대 20000
    ///   - page: 결과 페이지 번호. 1~45 사이 값 (기본값: 1)
    ///   - size: 한 페이지에 보여질 문서의 개수. 1~15 사이 값 (기본값: 15)
    /// - Returns: 키워드 검색 결과 응답
    /// - Throws: `KakaoSearchError`
    func fetchPlaceFromKeyword(query: String, x: String? = nil, y: String? = nil, radius: Int? = nil, page: Int? = nil, size: Int? = nil) async throws -> KakaoKeywordToPlaceResponseDTO {
        let fullURL = try URLBuilder.build(
            baseURL: URLConstant.kakaoKeywordToPlaceURL,
            parameters: [
                "query": query,
                "x": x,
                "y": y,
                "radius": radius,
                "page": page,
                "size": size
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
