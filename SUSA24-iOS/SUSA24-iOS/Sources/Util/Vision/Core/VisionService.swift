//  VisionService.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import Foundation
import CoreVideo
import Vision

/// Vision Framework 기능을 제공하는 Actor 기반 서비스
///
/// ## 주요 기능
/// - 실시간 문서 감지 (DocumentDetectionProcessor 사용)
/// - 렌즈 얼룩 감지
/// - 단일/배치 이미지 주소 추출
///
/// ## 아키텍처
/// - DocumentAnalyzer: RecognizeDocumentsRequest 처리
/// - DocumentDetectionProcessor: 실시간 프레임 분석
/// - AddressExtractor: 주소 추출 로직 통합
actor VisionService: VisionServiceProtocol {
    
    // MARK: - Dependencies
    
    private let documentAnalyzer: DocumentAnalyzer
    private let documentDetector: DocumentDetectionProcessor
    
    // MARK: - Initialization
    
    init(
        documentAnalyzer: DocumentAnalyzer = DocumentAnalyzer(),
        documentDetector: DocumentDetectionProcessor = DocumentDetectionProcessor()
    ) {
        self.documentAnalyzer = documentAnalyzer
        self.documentDetector = documentDetector
    }
    
    // MARK: - 실시간 감지
    
    func startDocumentDetection(
        frameStream: AsyncStream<CVImageBuffer>
    ) async -> AsyncStream<DocumentDetectionResult> {
        return documentDetector.getResultStream()
    }
    
    func startLensSmudgeDetection(
        frameStream: AsyncStream<CVImageBuffer>
    ) async -> AsyncStream<LensSmudgeDetectionResult> {
        return documentDetector.getSmudgeStream()
    }
    
    // MARK: - 주소 추출 (단일 이미지)
    
    func extractAddresses(
        from imageData: Data
    ) async throws -> AddressExtractionResult {
        // 1. 문서 분석 (테이블 + 텍스트)
        let analysisResult = try await documentAnalyzer.analyzeDocument(from: imageData)
        
        // 2. 주소 추출 (통합 메서드 사용)
        let addresses = await AddressExtractor.extractAddressesFromAnalysis(analysisResult)
        
        // 3. 중복 카운팅
        let countedAddresses = try await DuplicateCounter.countDuplicates(addresses)
        
        // 4. 소스 구분 (테이블 vs 텍스트)
        let extractionSource: AddressExtractionSource
        let tableAddresses: [String]
        let textAddresses: [String]
        
        if let tables = analysisResult.tables, !tables.isEmpty {
            extractionSource = .table
            tableAddresses = addresses
            textAddresses = []
        } else {
            extractionSource = .text
            tableAddresses = []
            textAddresses = addresses
        }
        
        // 5. 결과 반환
        return AddressExtractionResult(
            addresses: countedAddresses,
            tableAddresses: tableAddresses,
            textAddresses: textAddresses,
            extractionSource: extractionSource,
            tables: analysisResult.tables,
            document: analysisResult.document,
            extractedAt: Date()
        )
    }
    
    // MARK: - 주소 추출 (배치)
    
    func extractAddressesBatchWithProgress(
        from photos: [Data],
        progressHandler: @Sendable @escaping (Int, Int) async -> Void
    ) async throws -> [String: Int] {
        var allAddresses: [String] = []
        let total = photos.count
        
        // TaskGroup으로 병렬 처리
        await withTaskGroup(of: (Int, [String]).self) { group in
            for (index, photoData) in photos.enumerated() {
                group.addTask {
                    do {
                        // 문서 분석
                        let analysisResult = try await self.documentAnalyzer.analyzeDocument(from: photoData)
                        
                        // 주소 추출 (통합 메서드 사용)
                        let addresses = await AddressExtractor.extractAddressesFromAnalysis(analysisResult)
                        
                        // 진행률 업데이트
                        await progressHandler(index + 1, total)
                        
                        return (index, addresses)
                    } catch {
                        await progressHandler(index + 1, total)
                        return (index, [])
                    }
                }
            }
            
            // 결과 수집 (순서 유지)
            var results: [(Int, [String])] = []
            for await result in group {
                results.append(result)
            }
            
            // 순서대로 정렬하여 주소 병합
            for (_, addresses) in results.sorted(by: { $0.0 < $1.0 }) {
                allAddresses.append(contentsOf: addresses)
            }
        }
        
        // 중복 카운팅
        return try await DuplicateCounter.countDuplicates(allAddresses)
    }
    
    // MARK: - Cleanup
    
    /// 리소스를 정리합니다.
    func cleanup() async {
        await documentDetector.cleanup()
    }
}
