//
//  String+Validation.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/25/25.
//

extension String {
    /// 이모지가 포함되어 있는지 확인합니다.
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            // 실제 이모지 프레젠테이션 체크
            if scalar.properties.isEmojiPresentation {
                return true
            }
            
            // isEmoji이지만 ASCII가 아닌 경우 (실제 이모지)
            if scalar.properties.isEmoji, !scalar.isASCII {
                return true
            }
            
            // Variation Selector
            if (0xFE00 ... 0xFE0F).contains(scalar.value) {
                return true
            }
            
            // Zero Width Joiner
            if scalar.value == 0x200D {
                return true
            }
        }
        return false
    }
    
    /// 이모지를 제거한 문자열을 반환합니다.
    var removingEmojis: String {
        unicodeScalars
            .filter { scalar in
                // 실제 이모지 프레젠테이션 차단
                if scalar.properties.isEmojiPresentation {
                    return false
                }
                
                // isEmoji이지만 ASCII가 아닌 경우 차단
                if scalar.properties.isEmoji, !scalar.isASCII {
                    return false
                }
                
                // Variation Selector 제거
                if (0xFE00 ... 0xFE0F).contains(scalar.value) {
                    return false
                }
                
                // Zero Width Joiner 제거
                if scalar.value == 0x200D {
                    return false
                }
                
                return true
            }
            .map(String.init)
            .joined()
    }
}
