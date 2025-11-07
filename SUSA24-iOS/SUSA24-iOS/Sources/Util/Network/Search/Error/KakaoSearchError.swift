//
//  KakaoSearchError.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Alamofire
import Foundation

/// 카카오 검색 API 에러 타입
enum KakaoSearchError: LocalizedError, Sendable {
    case invalidURL
    case noResults
    case decodingFailed(DecodingError)
    case requestFailed(AFError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .noResults:
            "No address found for the given coordinates"
        case let .decodingFailed(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .requestFailed(error):
            "Request failed: \(error.localizedDescription)"
        case let .unknown(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}
