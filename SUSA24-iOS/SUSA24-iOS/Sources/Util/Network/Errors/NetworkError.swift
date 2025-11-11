//
//  NetworkError.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Alamofire
import Foundation

/// 네트워크 클라이언트 에러
enum NetworkError: LocalizedError {
    case decodingFailed(DecodingError)
    case requestFailed(AFError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case let .decodingFailed(error):
            "응답 파싱 실패: \(error.localizedDescription)"
        case let .requestFailed(error):
            "네트워크 요청 실패: \(error.localizedDescription)"
        case let .unknown(error):
            "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
    
    /// 복구 가능한 에러인지 여부
    var isRecoverable: Bool {
        switch self {
        case .requestFailed:
            true
        case .decodingFailed, .unknown:
            false
        }
    }
}
