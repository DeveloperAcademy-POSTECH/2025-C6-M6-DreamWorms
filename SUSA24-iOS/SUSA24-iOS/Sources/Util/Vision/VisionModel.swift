//
//  VisionModel.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import SwiftUI
import Vision

/// Vision Framework를 사용한 주소 추출 모델
/// @Observable을 사용하여 MainActor 아님 (백그라운드에서 실행)
@Observable
final class VisionModel {
    /// 추출된 주소 및 개수: [주소: 중복 횟수]
    var addresses: [String: Int] = [:]
    
    /// 테이블에서 추출된 주소들
    var tableAddresses: [String] = []

    /// 리스트 기반 주소
    var listAddresses: [String] = []

    /// 텍스트 기반 주소
    var textAddresses: [String] = []

    /// 분석 진행 여부
    var isAnalyzing: Bool = false

    /// 마지막 추출 결과
    var lastResult: AddressExtractionResult?

    /// 마지막 에러
    var lastError: VisionAnalysisError?

    // MARK: - Public API

    /// 단일 이미지에서 주소 추출
    func recognizeAddress(from imageData: Data) async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            // 1) 문서 구조 분석
            let analysis = try await DocumentAnalyzer.analyzeDocument(from: imageData)

            // 2) 주소 추출
            let result = await extractAddresses(from: analysis)

            // 3) UI 업데이트 (MainActor)
            await MainActor.run {
                self.addresses = result.addresses
                self.tableAddresses = result.tableAddresses
                self.listAddresses = result.listAddresses
                self.textAddresses = result.textAddresses
                self.lastResult = result
                self.lastError = nil
            }

        } catch let error as VisionAnalysisError {
            await MainActor.run { self.lastError = error }
        } catch {
            await MainActor.run {
                self.lastError = .imageProcessingFailed(error.localizedDescription)
            }
        }
    }

    /// 내부 주소 추출 전체 로직 (service layer)
    private func extractAddresses(from analysis: DocumentAnalysisResult) async -> AddressExtractionResult {
        var collected: [String] = []
        var source: AddressExtractionSource = .text

        // MARK: 1) 테이블 우선

        if !analysis.tables.isEmpty {
            source = .table

            var tablesMerged: [String] = []
            for table in analysis.tables {
                let col = await AddressExtractor.extractAddressColumnFromTable(table)
                tablesMerged.append(contentsOf: col)
            }

            collected = await AddressExtractor.extractAddressesFromText(
                tablesMerged.joined(separator: " ")
            )

            return AddressExtractionResult(
                addresses: DuplicateCounter.countDuplicates(collected),
                tableAddresses: tablesMerged,
                listAddresses: [],
                textAddresses: [],
                source: source,
                document: analysis.document,
                tables: analysis.tables,
                lists: analysis.lists
            )
        }

        // MARK: 2) 리스트 구조 있을 때

        if !analysis.lists.isEmpty {
            source = .list

            var listsMerged: [String] = []

            for list in analysis.lists {
                for item in list.items { // 각 리스트 항목 텍스트
                    let text = item.itemString
                    let found = KoreanAddressPattern.extractAddresses(from: text)
                    listsMerged.append(contentsOf: found)
                }
            }

            let normalized = await AddressExtractor.extractAddressesFromText(
                listsMerged.joined(separator: " ")
            )

            return AddressExtractionResult(
                addresses: DuplicateCounter.countDuplicates(normalized),
                tableAddresses: [],
                listAddresses: normalized,
                textAddresses: [],
                source: source,
                document: analysis.document,
                tables: analysis.tables,
                lists: analysis.lists
            )
        }

        // MARK: 3) 텍스트 기반 최후 fallback

        let textExtract = await AddressExtractor.extractAddressesFromText(analysis.recognizedText)

        return AddressExtractionResult(
            addresses: DuplicateCounter.countDuplicates(textExtract),
            tableAddresses: [],
            listAddresses: [],
            textAddresses: textExtract,
            source: .text,
            document: analysis.document,
            tables: analysis.tables,
            lists: analysis.lists
        )
    }

    // MARK: - Utilities

    func clearResults() {
        addresses = [:]
        tableAddresses = []
        listAddresses = []
        textAddresses = []
        lastResult = nil
        lastError = nil
    }

    var totalCount: Int { addresses.values.reduce(0, +) }
    var uniqueCount: Int { addresses.count }

    func topAddresses(count: Int = 10) -> [(String, Int)] {
        DuplicateCounter.topAddresses(addresses, topN: count)
    }

    var isEmpty: Bool { addresses.isEmpty }
}
