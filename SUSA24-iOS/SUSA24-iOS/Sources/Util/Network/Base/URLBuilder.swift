//
//  URLBuilder.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/5/25.
//

import Foundation

/// URL 쿼리 파라미터 조합을 위한 유틸리티
enum URLBuilder {
    /// Base URL과 쿼리 파라미터를 조합하여 완전한 URL 문자열을 생성합니다.
    /// - Parameters:
    ///   - baseURL: 기본 URL 문자열
    ///   - parameters: 쿼리 파라미터 딕셔너리 (nil 값은 자동으로 제외됨)
    /// - Returns: 쿼리 파라미터가 포함된 완전한 URL 문자열
    /// - Throws: `URLError` (잘못된 URL인 경우)
    static func build(
        baseURL: String,
        parameters: [String: String?]
    ) throws -> String {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // nil이 아닌 값만 필터링하여 쿼리 아이템 생성
        let queryItems = parameters
            .compactMapValues { $0 }  // nil 값 제거
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }
        
        return finalURL.absoluteString
    }
    
    /// Base URL과 쿼리 파라미터를 조합하여 완전한 URL 문자열을 생성합니다. (에러 없이 옵셔널 반환)
    /// - Parameters:
    ///   - baseURL: 기본 URL 문자열
    ///   - parameters: 쿼리 파라미터 딕셔너리 (nil 값은 자동으로 제외됨)
    /// - Returns: 쿼리 파라미터가 포함된 완전한 URL 문자열, 실패 시 nil
    static func buildOptional(
        baseURL: String,
        parameters: [String: String?]
    ) -> String? {
        try? build(baseURL: baseURL, parameters: parameters)
    }
}

// MARK: - Convenience Extensions

extension URLBuilder {
    /// Int 타입 파라미터를 지원하는 오버로드
    static func build(
        baseURL: String,
        parameters: [String: Any?]
    ) throws -> String {
        // Any? 타입을 String?로 변환
        let stringParameters = parameters.mapValues { value -> String? in
            guard let value = value else { return nil }
            
            if let string = value as? String {
                return string
            } else if let int = value as? Int {
                return String(int)
            } else if let double = value as? Double {
                return String(double)
            } else if let bool = value as? Bool {
                return String(bool)
            } else {
                return String(describing: value)
            }
        }
        
        return try build(baseURL: baseURL, parameters: stringParameters)
    }
    
    /// Int 타입 파라미터를 지원하는 오버로드 (옵셔널 반환)
    static func buildOptional(
        baseURL: String,
        parameters: [String: Any?]
    ) -> String? {
        try? build(baseURL: baseURL, parameters: parameters)
    }
}

