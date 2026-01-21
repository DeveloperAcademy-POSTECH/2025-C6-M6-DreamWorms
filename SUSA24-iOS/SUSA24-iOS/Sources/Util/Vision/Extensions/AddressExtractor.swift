//
//  AddressExtractor.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation
import Vision

enum AddressExtractor {
    // 타입 짧게 쓰려고 별칭
    typealias Table = DocumentObservation.Container.Table
    typealias Cell = DocumentObservation.Container.Table.Cell

    /// 테이블에서 "주소" 컬럼/행을 찾아 주소 텍스트를 추출한다.
    /// - 전치(Transpose)까지 지원
    static func extractAddressColumnFromTable(_ table: Table) async -> [String] {
        let grid = makeGrid(from: table) // [[Cell]]

        // 1) 원본 그리드에서 헤더 탐색
        if let result = await extractUsingHeaderDetection(grid: grid) {
            return result
        }

        // 2) 전치된 그리드에서 다시 헤더 탐색
        let transposedGrid = transpose(grid: grid)
        if let result = await extractUsingHeaderDetection(grid: transposedGrid) {
            print("🔄 [AddressExtractor] Transposed table detected, using transposed grid")
            return result
        }

        // 3) 그래도 못 찾으면 전체 fallback 스캔
        return fallbackScan(table: table)
    }

    /// 일반 텍스트에서 한국 주소를 추출한다.
    static func extractAddressesFromText(_ text: String) async -> [String] {
        KoreanAddressPattern
            .extractAddresses(from: text)
            .map { KoreanAddressPattern.normalize($0) }
            .filter { !$0.isEmpty }
    }

    /// 주소 배열을 정규화 + 중복 제거한 뒤 정렬한다.
    static func normalizeAddresses(_ addresses: [String]) -> [String] {
        Array(Set(addresses)).sorted()
    }

    /// Vision Table을 2차원 Cell 배열로 변환한다.
    private static func makeGrid(from table: Table) -> [[Cell]] {
        var grid: [[Cell]] = []
        for row in table.rows {
            grid.append(Array(row))
        }
        return grid
    }

    /// 2차원 Cell 배열을 전치(행<->열)한다.
    private static func transpose(grid: [[Cell]]) -> [[Cell]] {
        guard let firstRow = grid.first, !firstRow.isEmpty else { return grid }

        let rowCount = grid.count
        let colCount = firstRow.count

        var transposed: [[Cell]] = Array(
            repeating: [],
            count: colCount
        )

        for col in 0 ..< colCount {
            var newRow: [Cell] = []
            for row in 0 ..< rowCount {
                if col < grid[row].count {
                    newRow.append(grid[row][col])
                }
            }
            transposed[col] = newRow
        }

        return transposed
    }

    /// 2차원 Cell 배열에서 "주소" 헤더를 찾아, 해당 컬럼/행의 값을 추출한다.
    ///
    /// 시도 순서:
    /// 1. 첫 행을 헤더로 보고 "주소" 컬럼 찾기 → 그 아래 값들 추출 (가로 헤더)
    /// 2. 첫 열을 헤더로 보고 "주소" 행 찾기   → 그 오른쪽 값들 추출 (세로 헤더)
    private static func extractUsingHeaderDetection(grid: [[Cell]]) async -> [String]? {
        guard !grid.isEmpty, !grid[0].isEmpty else { return nil }

        let rowCount = grid.count
        _ = grid[0].count

        // 1) 가로 헤더: 첫 번째 행에서 "주소" 셀 찾기
        let headerRow = grid[0]
        var headerColumnIndex: Int?

        for (idx, cell) in headerRow.enumerated() {
            let raw = cell.content.text.transcript
            let text = raw.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if isAddressHeader(text) {
                headerColumnIndex = idx
                break
            }
        }

        if let colIdx = headerColumnIndex {
            var collected: [String] = []

            // 헤더 행을 제외하고 아래 행들에서 해당 컬럼 값만 수집
            for r in 1 ..< rowCount {
                guard colIdx < grid[r].count else { continue }
                let text = grid[r][colIdx].content.text.transcript
                collected.append(text)
            }

            return await normalizeAndExtract(collected)
        }

        // 2) 세로 헤더: 첫 번째 열에서 "주소" 셀 찾기
        var headerRowIndex: Int?

        for r in 0 ..< rowCount {
            guard !grid[r].isEmpty else { continue }
            let raw = grid[r][0].content.text.transcript
            let text = raw.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if isAddressHeader(text) {
                headerRowIndex = r
                break
            }
        }

        if let rowIdx = headerRowIndex {
            var collected: [String] = []

            // 헤더 셀(첫 열)을 제외하고 같은 행의 나머지 셀들을 수집
            let row = grid[rowIdx]
            if row.count > 1 {
                for c in 1 ..< row.count {
                    let text = row[c].content.text.transcript
                    collected.append(text)
                }
            }

            return await normalizeAndExtract(collected)
        }

        return nil
    }

    // MARK: - FALLBACK 스캔

    // ---------------------------------------------------------------------

    /// 헤더를 찾지 못했을 때, 테이블 전체 셀을 훑어서 한국 주소를 직접 추출한다.
    private static func fallbackScan(table: Table) -> [String] {
        var extracted: [String] = []

        for row in table.rows {
            for cell in row {
                let text = cell.content.text.transcript
                let found = KoreanAddressPattern.extractAddresses(from: text)
                extracted.append(contentsOf: found)
            }
        }

        return extracted
    }

    // MARK: - HELPERS

    // ---------------------------------------------------------------------

    /// 추출된 raw 문자열 배열을 하나의 텍스트로 합쳐서, 다시 정규식 기반 주소 추출을 수행한다.
    private static func normalizeAndExtract(_ raw: [String]) async -> [String] {
        await extractAddressesFromText(raw.joined(separator: " "))
    }

    /// 헤더 셀 텍스트가 "주소" 헤더인지 판별한다.
    private static func isAddressHeader(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .lowercased()

        if t.contains("주소") { return true } // 한국어
        if t.contains("住所") { return true } // 일본어
        if t.contains("address") { return true } // 영어

        return false
    }
}
