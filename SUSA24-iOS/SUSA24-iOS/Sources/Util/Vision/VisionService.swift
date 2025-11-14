//
//  VisionService.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import CoreVideo
import Foundation
import Vision

final class VisionService: VisionServiceProtocol, Sendable {
    // MARK: - Dependencies

    private let documentDetector: DocumentDetectionProcessor

    // MARK: - Init

    init(documentDetector: DocumentDetectionProcessor = DocumentDetectionProcessor()) {
        self.documentDetector = documentDetector
    }

    // MARK: - Realtime Detection

    func startDocumentDetection(
        frameStream _: AsyncStream<CVImageBuffer>
    ) async -> AsyncStream<DocumentDetectionResult> {
        documentDetector.getResultStream()
    }

    func startLensSmudgeDetection(
        frameStream _: AsyncStream<CVImageBuffer>
    ) async -> AsyncStream<LensSmudgeDetectionResult> {
        documentDetector.getSmudgeStream()
    }

    // MARK: - Address Extraction (Single)

    func extractAddresses(from imageData: Data) async throws -> AddressExtractionResult {
        let analysis = try await DocumentAnalyzer.analyzeDocument(from: imageData)

        // 1) 테이블 우선
        if !analysis.tables.isEmpty {
            return await extractFromTables(analysis)
        }

        // 2) 리스트
        if !analysis.lists.isEmpty {
            return await extractFromLists(analysis)
        }

        // 3) 텍스트
        return await extractFromText(analysis)
    }

    private func extractFromTables(_ analysis: DocumentAnalysisResult) async -> AddressExtractionResult {
        var tableCells: [String] = []

        for table in analysis.tables {
            let col = await AddressExtractor.extractAddressColumnFromTable(table)
            tableCells.append(contentsOf: col)
        }

        let normalized = await AddressExtractor.extractAddressesFromText(
            tableCells.joined(separator: " ")
        )
        let counted = DuplicateCounter.countDuplicates(normalized)

        return AddressExtractionResult(
            addresses: counted,
            tableAddresses: tableCells,
            listAddresses: [],
            textAddresses: [],
            source: .table,
            document: analysis.document,
            tables: analysis.tables,
            lists: analysis.lists,
            extractedAt: Date()
        )
    }

    private func extractFromLists(_ analysis: DocumentAnalysisResult) async -> AddressExtractionResult {
        var rawListAddresses: [String] = []

        for list in analysis.lists {
            for item in list.items {
                let text = item.itemString
                let found = KoreanAddressPattern.extractAddresses(from: text)
                rawListAddresses.append(contentsOf: found)
            }
        }

        let normalized = await AddressExtractor.extractAddressesFromText(
            rawListAddresses.joined(separator: " ")
        )
        let counted = DuplicateCounter.countDuplicates(normalized)

        return AddressExtractionResult(
            addresses: counted,
            tableAddresses: [],
            listAddresses: normalized,
            textAddresses: [],
            source: .list,
            document: analysis.document,
            tables: analysis.tables,
            lists: analysis.lists,
            extractedAt: Date()
        )
    }

    private func extractFromText(_ analysis: DocumentAnalysisResult) async -> AddressExtractionResult {
        let normalized = await AddressExtractor.extractAddressesFromText(analysis.recognizedText)
        let counted = DuplicateCounter.countDuplicates(normalized)

        return AddressExtractionResult(
            addresses: counted,
            tableAddresses: [],
            listAddresses: [],
            textAddresses: normalized,
            source: .text,
            document: analysis.document,
            tables: analysis.tables,
            lists: analysis.lists,
            extractedAt: Date()
        )
    }

    // MARK: - Address Extraction (Batch)

    func extractAddressesBatch(from photos: [Data]) async throws -> [String: Int] {
        try await extractAddressesBatchWithProgress(from: photos) { _, _ in }
    }

    func extractAddressesBatchWithProgress(
        from photos: [Data],
        progressHandler: @Sendable @escaping (Int, Int) async -> Void
    ) async throws -> [String: Int] {
        var merged: [String: Int] = [:]

        for (index, data) in photos.enumerated() {
            await progressHandler(index + 1, photos.count)

            do {
                let result = try await extractAddresses(from: data)
                merged = DuplicateCounter.mergeDictionaries(merged, result.addresses)
            } catch {
                continue
            }
        }

        return merged
    }

    // MARK: - Cleanup

    func cleanup() async {
        await documentDetector.cleanup()
    }
}
