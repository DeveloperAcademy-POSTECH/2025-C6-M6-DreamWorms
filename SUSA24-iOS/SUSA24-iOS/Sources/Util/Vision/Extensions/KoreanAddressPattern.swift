//
//  KoreanAddressPattern.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//  Updated: Stricter pattern to match only real addresses
//

import Foundation

/// 한국 주소 패턴 정의 (개선: 주소만 정확하게 매칭)
enum KoreanAddressPattern {
    // MARK: - 도로명 주소 정규식 (엄격)

    /// 도로명 주소: "로" 또는 "길" 필수
    /// 예: 테헤란로 152, 포항역로 1, 판교역로 235
    ///
    /// 최소 요구사항:
    /// - "로" 또는 "길" 포함 필수
    /// - 도로명 뒤에 번지 필수
    /// - 전체 길이 8자 이상
    static let streetAddressRegex: NSRegularExpression = {
        let pattern = "[가-힣A-Za-z·\\d~\\-\\.]{2,}(?:로|길)\\s*\\d+(?:[~\\-]\\d+)?"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    // MARK: - 지번 주소 정규식 (엄격)

    /// 지번 주소: "읍", "면", "동" 필수
    /// 예: 역삼동 737, 우동 1408, 흥해읍 1
    ///
    /// 최소 요구사항:
    /// - "읍", "면", "동" 중 하나 필수
    /// - 뒤에 번지 필수
    /// - 전체 길이 6자 이상
    static let lotAddressRegex: NSRegularExpression = {
        // "우동", "삼동" 같은 1~2글자 동명도 지원
        let pattern = "[가-힣]{1,}(?:읍|동|면)\\s+(?:\\d+(?:[~\\-]\\d+)?|산\\s*\\d+(?:[~\\-]\\d+)?)"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    // MARK: - 통합 한국 주소 정규식 (엄격)

    /// 통합 한국 주소 정규식
    ///
    /// ## 핵심 규칙
    /// 1. "읍/면/동" 또는 "로/길" 중 하나는 **필수**
    /// 2. 도/시/군/구는 선택적
    /// 3. 최소 길이 제한 (후처리에서 검증)
    ///
    /// ## 매칭되는 주소
    ///  경북 포항시 북구 흥해읍 포항역로 1
    ///  서울 강남구 테헤란로 152
    ///  서울 강남구 역삼동 737
    ///  부산 해운대구 우동 1408
    ///
    static let koreanAddressRegex: NSRegularExpression = {
        let pattern = """
        (?x)  # 확장 모드
        
        # 1. 광역시도 (선택)
        (?:
            (?:서울특별시|서울|
               부산광역시|부산|
               대구광역시|대구|
               인천광역시|인천|
               광주광역시|광주|
               대전광역시|대전|
               울산광역시|울산|
               세종특별자치시|세종|
               경기도|경기|
               강원특별자치도|강원도|강원|
               충청북도|충북|
               충청남도|충남|
               전북특별자치도|전라북도|전북|
               전라남도|전남|
               경상북도|경북|
               경상남도|경남|
               제주특별자치도|제주도|제주)
            \\s+
        )?
        
        # 2. 시 (선택, "시" 접미사도 선택)
        (?:[가-힣]{1,10}시\\s+)?
        
        # 3. 군/구 (선택)
        (?:[가-힣]{1,10}(?:군|구)\\s+)?
        
        # 4. 도로명 주소 (읍/면/동 선택 + 로/길 필수)
        (?:
            (?:[가-힣A-Za-z·\\d~\\-\\.]+(?:읍|동|면)\\s+)?  # 읍/면/동 (선택)
            [가-힣A-Za-z·\\d~\\-\\.]{2,}(?:로|길)\\s+      # 로/길 (필수)
            \\d+(?:[~\\-]\\d+)?                             # 번지 (필수)
        )
        |
        # 5. 지번 주소 (읍/면/동 필수)
        (?:
            [가-힣]{1,}(?:읍|동|면)\\s+                    # 읍/면/동 (필수, 1글자 이상)
            (?:\\d+(?:[~\\-]\\d+)?|산\\s*\\d+(?:[~\\-]\\d+)?)  # 번지 (필수)
        )
        """
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    // MARK: - 주소 추출 메서드 (검증 강화)

    /// 도로명 주소 추출 (검증 강화)
    static func extractStreetAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = streetAddressRegex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            let address = nsText.substring(with: match.range)
                .trimmingCharacters(in: .whitespaces)
            
            // 검증: 최소 길이 및 한글 포함 확인
            guard isValidAddress(address) else { return nil }
            
            return address
        }
    }

    /// 지번 주소 추출 (검증 강화)
    static func extractLotAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = lotAddressRegex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            let address = nsText.substring(with: match.range)
                .trimmingCharacters(in: .whitespaces)
            
            // 검증: 최소 길이 및 한글 포함 확인
            guard isValidAddress(address) else { return nil }
            
            return address
        }
    }

    /// 한국 주소 추출 (검증 강화)
    /// - Parameter text: 검색할 텍스트
    /// - Returns: 추출된 주소 배열
    ///
    /// ## 지원 형식
    /// ```
    ///  경북 포항시 북구 흥해읍 포항역로 1
    ///  경상북도 포항시 북구 흥해읍 포항역로 1
    ///  경북 포항 북구 흥해읍 포항역로 1        (시 생략)
    ///  서울특별시 강남구 테헤란로 152        (읍/면/동 생략)
    ///  서울 강남구 역삼동 737                (지번)
    ///  포항시 북구 흥해읍 포항역로 1         (도 생략)
    /// ```
    static func extractAddresses(from text: String) -> [String] {
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = koreanAddressRegex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            let address = nsText.substring(with: match.range)
                .trimmingCharacters(in: .whitespaces)
            
            // 검증: 최소 길이 및 한글 포함 확인
            guard isValidAddress(address) else {
                return nil
            }
            
            return address
        }
    }

    /// 한국 주소 형식 확인
    static func isKoreanAddress(_ text: String) -> Bool {
        let range = NSRange(location: 0, length: (text as NSString).length)
        let matches = koreanAddressRegex.matches(in: text, options: [], range: range)
        
        if matches.isEmpty {
            return false
        }
        
        // 추가 검증
        let matchedText = (text as NSString).substring(with: matches[0].range)
        return isValidAddress(matchedText)
    }

    /// 주소 정규화 (공백 정리)
    static func normalize(_ address: String) -> String {
        address
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    // MARK: - Private Validation
    
    /// 주소 유효성 검증 (추가 필터)
    ///
    /// ## 검증 규칙
    /// 1. 최소 길이: 5자 이상 (예: "우동 1408" → 7자)
    /// 2. 한글 포함: 최소 2자 이상 (짧은 동명 지원: "우동", "삼동")
    /// 3. "읍/면/동" 또는 "로/길" 중 하나 필수
    private static func isValidAddress(_ address: String) -> Bool {
        // 1. 최소 길이 체크 (5자 이상)
        guard address.count >= 5 else {
            return false
        }
        
        // 2. 한글 개수 체크 (최소 2자 - "우동", "삼동" 같은 짧은 동명 지원)
        let koreanCount = address.filter { char in
            let scalar = char.unicodeScalars.first!
            return (0xAC00 ... 0xD7A3).contains(scalar.value)
        }.count
        
        guard koreanCount >= 2 else {
            return false
        }
        
        // 3. "읍/면/동" 또는 "로/길" 필수 (주소 핵심 키워드)
        let hasEupMyeonDong = address.contains("읍") || address.contains("면") || address.contains("동")
        let hasRoGil = address.contains("로") || address.contains("길")
        
        guard hasEupMyeonDong || hasRoGil else {
            return false
        }
        
        // 4. 숫자 포함 체크 (주소는 반드시 번지 포함)
        let hasNumber = address.rangeOfCharacter(from: .decimalDigits) != nil
        
        guard hasNumber else {
            return false
        }
        
        return true
    }
}
