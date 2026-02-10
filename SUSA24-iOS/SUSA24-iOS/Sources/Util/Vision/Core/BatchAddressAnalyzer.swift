//
//  BatchAddressAnalyzer.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation
import Vision

/// 여러 이미지를 순차적으로 분석
///
/// Vision의 RecognizeDocumentsRequest 를 이미지마다 실행하고,
/// 주소 추출 결과를 병합하여 하나의 딕셔너리로 반환
///
/// - 모든 분석은 순차 처리
/// - 실패 이미지 스킵 가능
/// - 진행 상태 전달 가능
final class BatchAddressAnalyzer: Sendable {
    // MARK: - Progress Struct

    struct AnalysisProgress {
        let currentIndex: Int
        let totalCount: Int
        let currentPhoto: CapturedPhoto

        var percentage: Double {
            guard totalCount > 0 else { return 0 }
            return Double(currentIndex) / Double(totalCount)
        }
    }

    // MARK: - Result Struct

    struct BatchAnalysisResult {
        let addresses: [String: Int]
        let successCount: Int
        let failedCount: Int
        let totalCount: Int

        var isCompleted: Bool { successCount + failedCount == totalCount }
        var isEmpty: Bool { addresses.isEmpty }
    }

    // MARK: - Public API

    /// 여러 장의 사진을 순차적으로 주소 분석 수행
    func analyzePhotos(
        _ photos: [CapturedPhoto],
        progressHandler: (@MainActor (AnalysisProgress) async -> Void)? = nil
    ) async -> BatchAnalysisResult {
        // 0장 처리
        guard !photos.isEmpty else {
            return BatchAnalysisResult(
                addresses: [:],
                successCount: 0,
                failedCount: 0,
                totalCount: 0
            )
        }

        var merged: [String: Int] = [:]
        var success = 0
        var failed = 0

        // MARK: - 순차 처리

        for (index, photo) in photos.enumerated() {
            // 진행률 업데이트
            if let handler = progressHandler {
                await handler(AnalysisProgress(
                    currentIndex: index + 1,
                    totalCount: photos.count,
                    currentPhoto: photo
                ))
            }

            do {
                let extracted = try await analyzeSinglePhoto(photo)
                merged = DuplicateCounter.mergeDictionaries(merged, extracted)
                success += 1
            } catch {
                failed += 1
            }
        }

        return BatchAnalysisResult(
            addresses: merged,
            successCount: success,
            failedCount: failed,
            totalCount: photos.count
        )
    }

    // MARK: - Single Photo Analysis

    /// 단일 이미지의 주소 분석 수행
    ///
    /// 1) Vision Document Analyzer 로 테이블/리스트/텍스트 분석
    /// 2) 테이블 우선 주소 추출
    /// 3) 없으면 텍스트 주소 추출
    /// 4) 중복 제거 후 반환
    private func analyzeSinglePhoto(_ photo: CapturedPhoto) async throws -> [String: Int] {
        let analysis = try await DocumentAnalyzer.analyzeDocument(from: photo.data)

        var all: [String] = []

        // MARK: 우선순위 1. 테이블 기반

        if !analysis.tables.isEmpty {
            let extracted = await extractAddressFromTable(analysis.tables)
            all.append(contentsOf: extracted)
        }

        // MARK: 우선순위 2. 텍스트 기반

        else {
            let extracted = await extractAddressFromText(analysis.recognizedText)
            all.append(contentsOf: extracted)
        }

        // MARK: 중복 카운팅

        return DuplicateCounter.countDuplicates(all)
    }

    // MARK: - Private Helpers

    /// 테이블에서 주소를 추출
    private func extractAddressFromTable(
        _ tables: [DocumentObservation.Container.Table]
    ) async -> [String] {
        var collected: [String] = []

        for table in tables {
            let col = await AddressExtractor.extractAddressColumnFromTable(table)
            collected.append(contentsOf: col)
        }

        return await AddressExtractor.extractAddressesFromText(
            collected.joined(separator: " ")
        )
    }

    /// 텍스트에서 주소를 추출
    private func extractAddressFromText(_ text: String) async -> [String] {
        await AddressExtractor.extractAddressesFromText(text)
    }
}
