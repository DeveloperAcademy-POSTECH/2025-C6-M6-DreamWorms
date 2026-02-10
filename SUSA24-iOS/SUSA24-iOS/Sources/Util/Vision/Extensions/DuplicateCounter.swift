//
//  DuplicateCounter.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation

/// 주소 중복을 카운팅하는 헬퍼
enum DuplicateCounter {
    /// 주소 배열에서 중복을 제거하고 개수 카운트
    /// - Parameter addresses: 주소 배열
    /// - Returns: [주소: 개수] 딕셔너리
    static func countDuplicates(_ addresses: [String]) -> [String: Int] {
        var countDict: [String: Int] = [:]
        
        for address in addresses {
            let normalized = KoreanAddressPattern.normalize(address)
            guard !normalized.isEmpty else { continue }
            
            countDict[normalized, default: 0] += 1
        }
        
        return countDict
    }
    
    /// 주소 개수 딕셔너리를 개수 기준으로 정렬 (내림차순)
    /// - Parameter addressCount: [주소: 개수] 딕셔너리
    /// - Returns: 정렬된 배열 [(주소, 개수)]
    static func sortByCount(_ addressCount: [String: Int]) -> [(address: String, count: Int)] {
        addressCount
            .sorted { $0.value > $1.value }
            .map { (address: $0.key, count: $0.value) }
    }
    
    /// 최소 개수 이상의 주소들만 필터링
    /// - Parameters:
    ///   - addressCount: [주소: 개수] 딕셔너리
    ///   - minimumCount: 최소 개수 (기본값: 1)
    /// - Returns: 필터링된 딕셔너리
    static func filterByMinimumCount(_ addressCount: [String: Int], minimumCount: Int = 1) -> [String: Int] {
        addressCount.filter { $0.value >= minimumCount }
    }
    
    /// 전체 주소 배열 중 Top N 주소를 반환
    /// - Parameters:
    ///   - addressCount: [주소: 개수] 딕셔너리
    ///   - topN: 반환할 상위 개수 (기본값: 10)
    /// - Returns: 상위 N개 주소 [(주소, 개수)]
    static func topAddresses(_ addressCount: [String: Int], topN: Int = 10) -> [(address: String, count: Int)] {
        Array(sortByCount(addressCount).prefix(topN))
    }
    
    /// 여러 주소 배열을 합쳐서 개수 카운트
    /// - Parameter addressArrays: 주소 배열들
    /// - Returns: [주소: 개수] 딕셔너리
    static func mergeCounts(_ addressArrays: [[String]]) -> [String: Int] {
        let flatAddresses = addressArrays.flatMap(\.self)
        return countDuplicates(flatAddresses)
    }
    
    /// 두 주소 딕셔너리를 병합
    /// - Parameters:
    ///   - first: 첫 번째 딕셔너리
    ///   - second: 두 번째 딕셔너리
    /// - Returns: 병합된 딕셔너리 (개수 합산)
    static func mergeDictionaries(_ first: [String: Int], _ second: [String: Int]) -> [String: Int] {
        var result = first
        for (address, count) in second {
            result[address, default: 0] += count
        }
        return result
    }
}
