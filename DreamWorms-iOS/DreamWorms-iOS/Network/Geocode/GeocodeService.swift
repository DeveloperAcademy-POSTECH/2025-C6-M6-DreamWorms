//
//  GeocodeService.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/18/25.
//

import Alamofire
import Foundation

/// Naver Cloud Map Geocoding API 서비스
enum GeocodeService {
    /// 주소를 좌표로 변환합니다.
    /// - Parameter address: 검색할 주소 문자열
    /// - Returns: Address 객체 (위도, 경도 포함)
    /// - Throws: GeocodeError 또는 네트워크 에러
    static func geocode(address: String) async throws -> Address {
        let parameters: [String: String] = ["query": address]
        let headers: HTTPHeaders = [
            NetworkConstant.NaverAPIHeaderKey.clientID: Config.naverMapClientID,
            NetworkConstant.NaverAPIHeaderKey.clientSecret: Config.naverMapClientSecret,
        ]
        
        do {
            let response = try await AF.request(
                URLConstant.geocodeURL,
                method: .get,
                parameters: parameters,
                headers: headers
            )
            .serializingDecodable(GeocodeResponseDTO.self)
            .value
            
            guard response.status == "OK" else {
                throw GeocodeError.invalidStatus(response.status, response.errorMessage)
            }
            
            guard let address = response.addresses.first else {
                throw GeocodeError.noResults
            }
            return address
        } catch let error as GeocodeError {
            throw error
        } catch {
            throw GeocodeError.networkError(error)
        }
    }
}

enum GeocodeError: LocalizedError, Sendable {
    case invalidStatus(String, String)
    case noResults
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case let .invalidStatus(status, message):
            "Geocoding failed: \(status) - \(message)"
        case .noResults:
            "No results found"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        }
    }
}
