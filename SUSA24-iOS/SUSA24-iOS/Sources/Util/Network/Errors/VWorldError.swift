//
//  VWorldError.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

enum VWorldError: LocalizedError, Sendable {
    case noResults
    case invalidBounds
    case networkError(NetworkError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noResults:
            "CCTV 데이터가 없습니다"
        case .invalidBounds:
            "유효하지 않은 영역입니다"
        case let .networkError(error):
            "네트워크 오류: \(error.localizedDescription)"
        case let .unknown(error):
            "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .noResults, .invalidBounds:
            true
        case let .networkError(netError):
            netError.isRecoverable
        case .unknown:
            false
        }
    }
}
