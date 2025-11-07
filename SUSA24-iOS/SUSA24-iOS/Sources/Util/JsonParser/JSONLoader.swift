//
//  JSONLoader.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/3/25.
//

import Foundation

/// JSON 파일을 Bundle에서 로드하고 디코딩하는 유틸리티
enum JSONLoader {
    /// Bundle에서 JSON 파일을 로드하여 지정된 타입으로 디코딩합니다.
    ///
    /// - Parameters:
    ///   - filename: 로드할 JSON 파일명 (확장자 포함)
    ///   - type: 디코딩할 타입
    ///   - bundle: JSON 파일이 포함된 번들 (기본값: .main)
    ///   - decoder: 사용할 JSONDecoder (기본값: 표준 decoder with ISO8601 date decoding)
    /// - Returns: 디코딩된 데이터
    /// - Throws: `JSONLoaderError` 타입의 에러
    static func load<T: Decodable>(
        _ filename: String,
        as _: T.Type = T.self,
        from bundle: Bundle = .main,
        using decoder: JSONDecoder = .default
    ) throws -> T {
        guard let url = bundle.url(forResource: filename, withExtension: nil) else {
            throw JSONLoaderError.fileNotFound(filename)
        }
        
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw JSONLoaderError.dataLoadingFailed(filename, error)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONLoaderError.decodingFailed(filename, error)
        }
    }
    
    /// Bundle에서 JSON 파일을 비동기적으로 로드하여 지정된 타입으로 디코딩합니다.
    ///
    /// - Parameters:
    ///   - filename: 로드할 JSON 파일명 (확장자 포함)
    ///   - type: 디코딩할 타입
    ///   - bundle: JSON 파일이 포함된 번들 (기본값: .main)
    ///   - decoder: 사용할 JSONDecoder (기본값: 표준 decoder with ISO8601 date decoding)
    /// - Returns: 디코딩된 데이터
    /// - Throws: `JSONLoaderError` 타입의 에러
    static func loadAsync<T: Decodable & Sendable>(
        _ filename: String,
        as type: T.Type = T.self,
        from bundle: Bundle = .main,
        using decoder: JSONDecoder = .default
    ) async throws -> T {
        try await Task {
            try load(filename, as: type, from: bundle, using: decoder)
        }.value
    }
}

// MARK: - JSONLoaderError

enum JSONLoaderError: LocalizedError, Sendable {
    case fileNotFound(String)
    case dataLoadingFailed(String, Error)
    case decodingFailed(String, Error)
    
    var errorDescription: String? {
        switch self {
        case let .fileNotFound(filename):
            "JSON file not found: \(filename)"
        case let .dataLoadingFailed(filename, error):
            "Failed to load data from \(filename): \(error.localizedDescription)"
        case let .decodingFailed(filename, error):
            "Failed to decode JSON from \(filename): \(error.localizedDescription)"
        }
    }
}

// MARK: - JSONDecoder Extension

extension JSONDecoder {
    /// ISO8601 날짜 형식을 지원하는 기본 JSONDecoder
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
