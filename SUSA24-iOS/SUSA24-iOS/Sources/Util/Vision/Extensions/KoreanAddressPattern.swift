//
//  KoreanAddressPattern.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation

/// 한국 주소 패턴 정의
enum KoreanAddressPattern {
    // MARK: - 도로명 주소 정규식

    /// 도로명 주소: [도로명]{2,}(로|길)[번지]
    /// 예: 강서구 지사동 1197, 포항시 남구 지곡로 77
    static let streetAddressRegex: NSRegularExpression = {
        let pattern = "[가-힣A-Za-z·\\d~\\-\\.]{2,}(?:로|길).\\d+"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()
    
    // MARK: - 지번 주소 정규식

    /// 지번 주소: [지명]+(읍|동)[공백][번지]
    /// 예: 지사동 1299, 지사동 산 30, 법방동 1833
    static let lotAddressRegex: NSRegularExpression = {
        // 패턴 1: 지명+(읍|동) 공백 숫자-숫자
        let pattern1 = "[가-힣A-Za-z·\\d~\\-\\.]+(?:읍|동)\\s[\\d\\-]+"
        // 패턴 2: 지명+(읍|동) 공백 숫자+비시자
        let pattern2 = "[가-힣A-Za-z·\\d~\\-\\.]+(?:읍|동)\\s\\d[^시]+"
        let fullPattern = "(\(pattern1))|(\(pattern2))"
        return try! NSRegularExpression(pattern: fullPattern, options: [])
    }()
    
    // MARK: - 통합 한국 주소 정규식

    /// 도로명 + 지번 주소 모두 매칭
    static let koreanAddressRegex: NSRegularExpression = {
        // 광역시도를 포함한 전체 주소 패턴
        let pattern = """
        (?:[가-힣]{2,4}[시도])?\\s*[가-힣A-Za-z·\\d~\\-\\.]+(?:시|군|구)\\s+\
        (?:[가-힣A-Za-z·\\d~\\-\\.]+(?:읍|동)\\s+(?:\\d+(?:[~\\-]\\d+)?|산\\s*\\d+)|[가-힣A-Za-z·\\d~\\-\\.]{2,}(?:로|길).\\d+)
        """
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()
    
    /// 주어진 텍스트에서 도로명 주소를 추출합니다.
    /// - Parameter text: 검색할 텍스트
    /// - Returns: 추출된 도로명 주소 배열
    static func extractStreetAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        
        let matches = streetAddressRegex.matches(in: text, options: [], range: range)
        
        return matches
            .compactMap { match in
                let address = nsText.substring(with: match.range).trimmingCharacters(in: .whitespaces)
                return address.isEmpty ? nil : address
            }
    }
    
    /// 주어진 텍스트에서 지번 주소를 추출합니다.
    /// - Parameter text: 검색할 텍스트
    /// - Returns: 추출된 지번 주소 배열
    static func extractLotAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        
        let matches = lotAddressRegex.matches(in: text, options: [], range: range)
        
        return matches
            .compactMap { match in
                let address = nsText.substring(with: match.range).trimmingCharacters(in: .whitespaces)
                return address.isEmpty ? nil : address
            }
    }
    
    /// 주어진 텍스트에서 한국 주소를 추출합니다.
    /// - Parameter text: 검색할 텍스트
    /// - Returns: 추출된 주소 배열
    static func extractAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        
        let matches = koreanAddressRegex.matches(in: text, options: [], range: range)
        
        return matches
            .compactMap { match in
                let address = nsText.substring(with: match.range).trimmingCharacters(in: .whitespaces)
                return address.isEmpty ? nil : address
            }
    }
    
    /// 텍스트가 한국 주소 형식인지 확인합니다.
    /// - Parameter text: 확인할 텍스트
    /// - Returns: 주소 형식 여부
    static func isKoreanAddress(_ text: String) -> Bool {
        let range = NSRange(location: 0, length: (text as NSString).length)
        let matches = koreanAddressRegex.matches(in: text, options: [], range: range)
        return !matches.isEmpty
    }
    
    /// 주소 정규화 (정규식 매칭 후 공백 정리)
    /// - Parameter address: 정규화할 주소
    /// - Returns: 정규화된 주소
    static func normalize(_ address: String) -> String {
        address
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
