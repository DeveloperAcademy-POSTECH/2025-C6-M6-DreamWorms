//
//  LocalSearchService.swift
//  DreamWorms-iOS
//
//  Created by Assistant on 2025-01-27.
//

import Alamofire
import CoreLocation
import Foundation

struct LocalSearchResult: Sendable {
    let title: String
    let address: String
    let roadAddress: String
    let category: String
    let coordinate: CLLocationCoordinate2D
}

/// 네이버 지역 검색 API 서비스
enum LocalSearchService {
    /// 지역 검색을 수행합니다.
    /// - Parameter query: 검색할 키워드
    /// - Returns: 검색 결과 배열
    /// - Throws: LocalSearchError 또는 네트워크 에러
    static func search(query: String) async throws -> [LocalSearchResult] {
        let parameters: [String: String] = [
            "query": query,
            "display": "10",
        ]
        
        let headers: HTTPHeaders = [
            NetworkConstant.NaverSearchAPIHeaderKey.clientID: Config.naverSearchClientID,
            NetworkConstant.NaverSearchAPIHeaderKey.clientSecret: Config.naverSearchClientSecret,
        ]
        
        do {
            let response = try await AF.request(
                URLConstant.localSearchURL,
                method: .get,
                parameters: parameters,
                headers: headers
            )
            .serializingDecodable(SearchResponse.self)
            .value
            
            let results = response.items.map { item in
                let mapx = Double(item.mapx) ?? 0
                let mapy = Double(item.mapy) ?? 0
                
                // 네이버 API는 1000만분의 1 단위로 좌표 제공
                let coordinate = CLLocationCoordinate2D(
                    latitude: mapy / 10_000_000.0, // mapy가 위도
                    longitude: mapx / 10_000_000.0 // mapx가 경도
                )
                
                return LocalSearchResult(
                    title: item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression),
                    address: item.address,
                    roadAddress: item.roadAddress,
                    category: item.category,
                    coordinate: coordinate
                )
            }
            
            return results
            
        } catch {
            throw LocalSearchError.networkError(error)
        }
    }
}

// MARK: - LocalSearchError

enum LocalSearchError: LocalizedError, Sendable {
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case let .networkError(error):
            "네트워크 에러: \(error.localizedDescription)"
        }
    }
}

// MARK: - Response Models

nonisolated struct SearchResponse: Codable {
    let items: [SearchItem]
}

struct SearchItem: Codable {
    let title: String
    let address: String
    let roadAddress: String
    let category: String
    let mapx: String
    let mapy: String
}
