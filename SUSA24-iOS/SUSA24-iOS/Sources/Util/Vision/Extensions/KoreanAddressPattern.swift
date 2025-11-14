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

    /// 도로명 주소: [도로명](로|길)[번지]
    static let streetAddressRegex: NSRegularExpression = {
        let pattern = "[가-힣A-Za-z·\\d~\\-\\.]{2,}(?:로|길)\\s*\\d+"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    // MARK: - 지번 주소 정규식

    /// 지번 주소: [지명](읍|동|면) [번지]
    static let lotAddressRegex: NSRegularExpression = {
        let pattern1 = "[가-힣A-Za-z·\\d~\\-\\.]+(?:읍|동|면)\\s+[\\d\\-]+"
        let pattern2 = "[가-힣A-Za-z·\\d~\\-\\.]+(?:읍|동|면)\\s+\\d[^시]+"
        let fullPattern = "(\(pattern1))|(\(pattern2))"
        return try! NSRegularExpression(pattern: fullPattern, options: [])
    }()

    // MARK: - 통합 한국 주소 정규식

    /// 통합 한국 주소 정규식
    /// [광역시도(선택)] [시(선택)] [군/구(선택)] [읍/면/동(필수)] [번지(필수)]
    static let koreanAddressRegex: NSRegularExpression = {
        let pattern = """
        (?:(?:서울특별시|서울|부산광역시|부산|대구광역시|대구|인천광역시|인천|광주광역시|광주|대전광역시|대전|울산광역시|울산|세종특별자치시|세종|경기도|경기|강원특별자치도|강원도|강원|충청북도|충북|충청남도|충남|전북특별자치도|전라북도|전북|전라남도|전남|경상북도|경북|경상남도|경남|제주특별자치도|제주도|제주)\\s+)?(?:[가-힣]{2,5}시\\s+)?(?:[가-힣]{2,5}(?:군|구)\\s+)?[가-힣A-Za-z·\\d~\\-\\.]+(?:읍|동|면)\\s+(?:\\d+(?:[~\\-]\\d+)?|산\\s*\\d+)
        """
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    // MARK: - 주소 추출 메서드

    /// 도로명 주소 추출
    static func extractStreetAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = streetAddressRegex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            let address = nsText.substring(with: match.range)
                .trimmingCharacters(in: .whitespaces)
            return address.isEmpty ? nil : address
        }
    }

    /// 지번 주소 추출
    static func extractLotAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = lotAddressRegex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            let address = nsText.substring(with: match.range)
                .trimmingCharacters(in: .whitespaces)
            return address.isEmpty ? nil : address
        }
    }

    /// 한국 주소 추출 (도로명 + 지번 통합)
    static func extractAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = koreanAddressRegex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            let address = nsText.substring(with: match.range)
                .trimmingCharacters(in: .whitespaces)
            return address.isEmpty ? nil : address
        }
    }

    /// 한국 주소 형식 확인
    static func isKoreanAddress(_ text: String) -> Bool {
        let range = NSRange(location: 0, length: (text as NSString).length)
        let matches = koreanAddressRegex.matches(in: text, options: [], range: range)
        return !matches.isEmpty
    }

    /// 주소 정규화 (공백 정리)
    static func normalize(_ address: String) -> String {
        address
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
