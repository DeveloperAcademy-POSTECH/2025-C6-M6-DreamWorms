//
//  NetworkClient.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Alamofire
import Foundation

/// 범용 네트워크 클라이언트
/// - Session 등 무거운 리소스를 싱글톤으로 관리
final class NetworkClient: APIClient {
    static let shared = NetworkClient()
    private init() {}
    
    // MARK: - Properties
    
    /// Alamofire Session
    private let session: Session = {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 10
        return Session(configuration: config)
    }()
    
    // MARK: - Public Methods
    
    /// Endpoint 기반 네트워크 요청
    /// - Parameters:
    ///   - endpoint: API Endpoint
    ///   - decoder: JSON 디코더
    /// - Returns: 디코딩된 응답 객체
    /// - Throws: `NetworkError`
    func request<T: Decodable>(
        endpoint: Endpoint,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        do {
            let requestData = try await session
                .request(endpoint.url, method: endpoint.method, headers: endpoint.headers)
                .serializingData()
                .value
            return try decoder.decode(T.self, from: requestData)
            
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
            
        } catch let error as AFError {
            throw NetworkError.requestFailed(error)
            
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
