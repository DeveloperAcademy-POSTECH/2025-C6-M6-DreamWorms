//
//  DocumentAnalyzer.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import UIKit
import Vision

/// Vision Framework 기반 문서 분석 유틸리티
/// - 테이블, 리스트, 텍스트를 모두 분석하는 가장 핵심적인 Analyzer
/// - 모든 VisionService 및 BatchAddressAnalyzer가 이 결과를 기반으로 동작한다.
struct DocumentAnalyzer: Sendable {
    /// 이미지 데이터에서 문서(테이블 + 리스트 + 텍스트)를 분석한다.
    /// - Parameter imageData: 분석할 JPEG/PNG 데이터
    /// - Returns: DocumentAnalysisResult
    static func analyzeDocument(from imageData: Data) async throws -> DocumentAnalysisResult {
        let request = RecognizeDocumentsRequest()
        
        // MARK: Vision 요청 수행

        let observations = try await request.perform(on: imageData)
        
        guard let container = observations.first?.document else {
            throw VisionAnalysisError.documentDetectionFailed("문서를 감지하지 못했습니다.")
        }

        // MARK: - 요소 추출

        let tables = container.tables
        let lists = container.lists
        let text = container.text.transcript

        return DocumentAnalysisResult(
            tables: tables.isEmpty ? [] : tables,
            lists: lists.isEmpty ? [] : lists,
            recognizedText: text,
            document: container,
            analyzedAt: Date(),
            imageData: imageData
        )
    }

    /// 테이블만 추출
    static func extractTables(from imageData: Data) async throws -> [DocumentObservation.Container.Table] {
        let result = try await analyzeDocument(from: imageData)

        if result.tables.isEmpty {
            throw VisionAnalysisError.noTablesFound
        }
        return result.tables
    }
    
    /// 텍스트만 추출
    static func extractText(from imageData: Data) async throws -> String {
        let result = try await analyzeDocument(from: imageData)

        let text = result.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            throw VisionAnalysisError.noTextFound
        }
        return text
    }
}
