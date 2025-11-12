//
//  AddressExtractor.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation
import Vision

enum AddressExtractor {
    /// 문서 테이블에서 모든 주소를 추출합니다.
    /// - Parameter tables: DocumentObservation 테이블들
    /// - Returns: 추출된 주소 배열
    static func extractAddressesFromTable(_ tables: [DocumentObservation.Container.Table]) async -> [String] {
        var extractedAddresses: [String] = []
        
        for table in tables {
            // 테이블의 각 행(row)을 순회
            for row in table.rows {
                // 각 셀(cell)을 순회 (row 자체가 반복 가능)
                for cell in row {
                    // 셀의 텍스트 추출
                    let cellText = cell.content.text.transcript
                    
                    // 셀 텍스트가 한국 주소 형식인지 확인
                    let addresses = KoreanAddressPattern.extractAddresses(from: cellText)
                    extractedAddresses.append(contentsOf: addresses)
                }
            }
        }
        
        return extractedAddresses
    }
    
    /// 문서 텍스트에서 한국 주소 패턴을 추출합니다.
    /// - Parameter text: 검색할 텍스트
    /// - Returns: 추출된 주소 배열
    static func extractAddressesFromText(_ text: String) async -> [String] {
        let addresses = KoreanAddressPattern.extractAddresses(from: text)
        return addresses
            .map { KoreanAddressPattern.normalize($0) }
            .filter { !$0.isEmpty }
    }
    
    /// 추출된 주소 배열을 정규화합니다.
    /// - Parameter addresses: 정규화할 주소 배열
    /// - Returns: 정규화된 고유 주소 배열
    static func normalizeAddresses(_ addresses: [String]) -> [String] {
        Set(addresses.map { KoreanAddressPattern.normalize($0) })
            .sorted()
    }
    
    /// "주소" 컬럼을 찾아서 그 컬럼의 모든 셀 값을 반환합니다.
    /// - Parameter table: 검색할 테이블
    /// - Returns: 주소 컬럼의 셀 값 배열
    static func extractAddressColumnFromTable(_ table: DocumentObservation.Container.Table) async -> [String] {
        var addressColumnIndex: Int? = nil
        var addressCells: [String] = []
        
        // 첫 번째 행에서 "주소" 헤더 찾기
        if !table.rows.isEmpty {
            let headerRow = table.rows[0]
            for (index, cell) in headerRow.enumerated() {
                let cellText = cell.content.text.transcript
                
                if cellText.contains("주소") {
                    addressColumnIndex = index
                    break
                }
            }
        }
        
        // 주소 컬럼이 발견되면 해당 컬럼의 모든 값 추출
        if let columnIndex = addressColumnIndex {
            for row in table.rows.dropFirst() { // 헤더 행 제외
                // 행을 배열로 변환하여 인덱스 접근
                let rowCells = Array(row)
                if columnIndex < rowCells.count {
                    let cell = rowCells[columnIndex]
                    let cellText = cell.content.text.transcript
                    
                    if !cellText.isEmpty {
                        addressCells.append(cellText)
                    }
                }
            }
        }
        return addressCells
    }
}
