//
//  DocumentAnalyzer.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Vision
import UIKit

/// Vision Framework를 사용하여 문서를 분석하는 유틸리티
/// Stateless 구조체로 static 메서드만 제공합니다.
struct DocumentAnalyzer: Sendable {
    
    /// 이미지 데이터에서 문서를 인식하고 분석합니다.
    /// - Parameter imageData: 분석할 이미지 데이터
    /// - Returns: DocumentAnalysisResult
    /// - Throws: 분석 실패 시 VisionAnalysisError
    static func analyzeDocument(from imageData: Data) async throws -> DocumentAnalysisResult {
        let request = RecognizeDocumentsRequest()
        
        // Vision 요청 실행 (async/await)
        let observations = try await request.perform(on: imageData)
        
        // 첫 번째 문서 관찰 객체 추출
        guard let document = observations.first?.document else {
            throw VisionAnalysisError.documentDetectionFailed("문서를 감지하지 못했습니다")
        }
        
        // 테이블과 텍스트 추출
        let tables = document.tables
        let recognizedText = document.text.transcript
        
        return DocumentAnalysisResult(
            tables: tables.isEmpty ? nil : tables,
            recognizedText: recognizedText,
            analyzedAt: Date(),
            imageData: imageData
        )
    }
    
    /// 이미지에서 테이블 정보만 추출합니다.
    /// - Parameter imageData: 분석할 이미지 데이터
    /// - Returns: 발견된 테이블들
    /// - Throws: 분석 실패 시 VisionAnalysisError
    static func extractTables(from imageData: Data) async throws -> [DocumentObservation.Container.Table] {
        let request = RecognizeDocumentsRequest()
        
        // Vision 요청 실행
        let observations = try await request.perform(on: imageData)
        
        guard let document = observations.first?.document else {
            throw VisionAnalysisError.documentDetectionFailed("문서를 감지하지 못했습니다")
        }
        
        guard !document.tables.isEmpty else {
            throw VisionAnalysisError.noTablesFound
        }
        
        return document.tables
    }
    
    /// 이미지에서 텍스트만 추출합니다.
    /// - Parameter imageData: 분석할 이미지 데이터
    /// - Returns: 인식된 텍스트
    /// - Throws: 분석 실패 시 VisionAnalysisError
    static func extractText(from imageData: Data) async throws -> String {
        let request = RecognizeDocumentsRequest()
        
        // Vision 요청 실행
        let observations = try await request.perform(on: imageData)
        
        guard let document = observations.first?.document else {
            throw VisionAnalysisError.documentDetectionFailed("문서를 감지하지 못했습니다")
        }
        
        let text = document.text.transcript
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw VisionAnalysisError.noTextFound
        }
        
        return text
    }
}
