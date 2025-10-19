//
//  MessageParser.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/18/25.
//

import Foundation

enum MessageParser {
    /// 문자 메시지의 본문으로부터 주소를 추출합니다.
    /// - Parameter text: Message body
    /// - Returns: 주소 문자열. 없으면 nil
    nonisolated static func extractAddress(from text: String) -> String? {
        let addressPattern = "^(?=.*[가-힣])[가-힣0-9\\s]+$"
        guard !containsInvalidKeywords(from: text) else { return nil }
        return findAddress(from: text, pattern: addressPattern)?
            .trimmingCharacters(in: .whitespaces)
    }
        
    /// 확인불가를 의미하는 키워드가 포함되어 있는지 체크합니다.
    /// 공백, 괄호 변형도 감지합니다.
    /// - Parameter text: 검사할 문자열
    /// - Returns: 확인불가 키워드 포함 여부
    nonisolated static func containsInvalidKeywords(from text: String) -> Bool {
        let patterns = [
            // "확인불가", "확인 불가", "MSC 정보 확인 불가" 등
            // [ ]*: 공백(space) 0개 이상
            "확인[ ]*불가",
            
            // "전원상태(N)", "전원 상태(N)", "전원상태N" 등
            // [ ]*: 공백 0개 이상
            // \\(?: 여는 괄호 ( 0번 또는 1번
            // \\)?: 닫는 괄호 ) 0번 또는 1번
            "전원[ ]*상태[ ]*\\(?[ ]*N[ ]*\\)?",
        ]
        
        return patterns.contains { pattern in
            text.range(of: pattern, options: .regularExpression) != nil
        }
    }
    
    /// 패턴과 일치하는 첫 번째 주소 줄을 찾습니다.
    /// - Parameters:
    ///   - text: 검색할 문자열
    ///   - pattern: 정규표현식 패턴
    /// - Returns: 매칭된 주소 문자열. 없으면 nil
    nonisolated static func findAddress(from text: String, pattern: String) -> String? {
        // NSRegularExpression으로 패턴 매칭
        // .anchorsMatchLines: ^ 와 $ 가 전체 문자열이 아닌 각 줄의 시작/끝을 의미하도록 설정
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let matchRange = Range(match.range, in: text) else { return nil }
        return String(text[matchRange])
    }
}
