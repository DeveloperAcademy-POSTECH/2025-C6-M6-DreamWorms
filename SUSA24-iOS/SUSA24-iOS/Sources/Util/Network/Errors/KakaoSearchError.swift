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
    case noResults
    case invalidCoordinate
    case invalidQuery
    case networkError(NetworkError)
    case rateLimitExceeded
    case unauthorized
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noResults:
            "검색 결과가 없습니다"
        case .invalidCoordinate:
            "유효하지 않은 좌표입니다"
        case .invalidQuery:
            "검색어를 입력해주세요"
        case let .networkError(error):
            "네트워크 오류: \(error.localizedDescription)"
        case .rateLimitExceeded:
            "API 호출 한도를 초과했습니다"
        case .unauthorized:
            "API 키가 유효하지 않습니다"
        case let .unknown(error):
            "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
    
    /// 복구 가능한 에러인지 여부
    var isRecoverable: Bool {
        switch self {
        case .noResults, .invalidCoordinate, .invalidQuery:
            true
        case .rateLimitExceeded:
            true
        case let .networkError(netError):
            netError.isRecoverable
        case .unauthorized, .unknown:
            false
        }
    }
}
