//
//  MessageParser.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/10/25.
//

import Foundation

/// 메시지에서 기지국 위치 정보를 추출하는 유틸리티
enum MessageParser: Sendable {
    /// 문자 메시지 본문에서 주소를 추출합니다.
    /// - Parameter text: 메시지 본문
    /// - Returns: 추출된 주소 문자열 (예: "부산강서구지사동 1299"). 없으면 nil
    static func extractAddress(from text: String) -> String? {
        // 확인불가 키워드가 있으면 nil 반환
        guard !containsInvalidKeywords(from: text) else {
            return nil
        }

        // [발신기지국] 이후의 텍스트만 처리
        let lines = text.components(separatedBy: .newlines)

        // [발신기지국]이 포함된 줄의 인덱스 찾기
        guard let baseStationIndex = lines.firstIndex(where: { $0.contains("[발신기지국]") }) else {
            return nil
        }

        // [발신기지국] 다음 줄부터 처리
        let remainingLines = Array(lines.dropFirst(baseStationIndex + 1))

        // 1. 한글이 포함된 첫 번째 줄 찾기 (주소)
        guard let addressLineIndex = remainingLines.firstIndex(where: { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && trimmed.range(of: "[가-힣]", options: .regularExpression) != nil
        }) else {
            return nil
        }

        let addressLine = remainingLines[addressLineIndex].trimmingCharacters(in: .whitespaces)

        // 2. 다음 줄에서 첫 번째 숫자 그룹 추출 (쉼표나 괄호 전까지)
        var fullAddress = addressLine

        if addressLineIndex + 1 < remainingLines.count {
            let nextLine = remainingLines[addressLineIndex + 1].trimmingCharacters(in: .whitespaces)

            // 숫자로 시작하는 경우, 쉼표나 괄호 전까지만 추출
            if let firstNumber = extractFirstNumber(from: nextLine) {
                fullAddress += " \(firstNumber)"
            }
        }

        return fullAddress
    }

    /// 문자열에서 첫 번째 숫자 그룹을 추출합니다 (쉼표, 괄호 전까지)
    /// - Parameter text: 검색할 문자열
    /// - Returns: 첫 번째 숫자. 없으면 nil
    private static func extractFirstNumber(from text: String) -> String? {
        // 숫자로 시작하는지 확인
        guard let firstChar = text.first, firstChar.isNumber else {
            return nil
        }

        // 쉼표, 괄호, 공백이 나올 때까지 숫자만 추출
        var result = ""
        for char in text {
            if char.isNumber {
                result.append(char)
            } else if char == "," || char == "(" || char == " " {
                break
            } else {
                // 다른 문자가 나오면 계속 진행
                continue
            }
        }

        return result.isEmpty ? nil : result
    }

    /// 확인불가를 의미하는 키워드가 포함되어 있는지 체크합니다.
    /// - Parameter text: 검사할 문자열
    /// - Returns: 확인불가 키워드 포함 여부
    static func containsInvalidKeywords(from text: String) -> Bool {
        let patterns = [
            "확인[ ]*불가",
            "전원[ ]*상태[ ]*\\(?[ ]*N[ ]*\\)?",
        ]

        return patterns.contains { pattern in
            text.range(of: pattern, options: .regularExpression) != nil
        }
    }

    /// 패턴과 일치하는 첫 번째 주소를 찾습니다.
    /// - Parameters:
    ///   - text: 검색할 문자열
    ///   - pattern: 정규표현식 패턴
    /// - Returns: 매칭된 주소 문자열. 없으면 nil
    static func findAddress(from text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: .anchorsMatchLines
        ) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let matchRange = Range(match.range, in: text)
        else {
            return nil
        }

        return String(text[matchRange])
    }
}
