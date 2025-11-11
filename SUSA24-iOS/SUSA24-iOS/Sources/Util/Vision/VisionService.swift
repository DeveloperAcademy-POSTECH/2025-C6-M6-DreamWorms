//
//  VisionService.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import Foundation
import CoreVideo
import Vision

/// Vision Framework 기능을 제공하는 서비스
final class VisionService: VisionServiceProtocol, Sendable {
    
    // MARK: - Dependencies
    
    private let documentDetector: DocumentDetectionProcessor
    
    // MARK: - Initialization
    
    init(documentDetector: DocumentDetectionProcessor = DocumentDetectionProcessor()) {
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
    
    // MARK: - 주소 추출
    
    func extractAddresses(
        from imageData: Data
    ) async throws -> AddressExtractionResult {
        // 1. 문서 분석 (테이블 + 텍스트)
        let analysisResult = try await DocumentAnalyzer.analyzeDocument(from: imageData)
            
        var allAddresses: [String] = []
        var tableAddresses: [String] = []
        var textAddresses: [String] = []
        var extractionSource: AddressExtractionSource = .text
            
        // 2. 테이블이 있으면 테이블에서만 추출
        if let tables = analysisResult.tables, !tables.isEmpty {
            tableAddresses = await extractAddressFromTables(tables)
            allAddresses = tableAddresses
            extractionSource = .table
        } else {
            // 3. 테이블이 없으면 텍스트에서 추출
            textAddresses = await extractAddressFromText(analysisResult.recognizedText)
            allAddresses = textAddresses
            extractionSource = .text
        }
            
        // 4. 중복 카운팅
        let countedAddresses = DuplicateCounter.countDuplicates(allAddresses)
            
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
                        let result = try await DocumentAnalyzer.analyzeDocument(from: photoData)
                        let addresses = await self.extractAddressesFromAnalysisResult(result)
                            
                        // 진행률 업데이트
                        await progressHandler(index + 1, total)
                            
                        return (index, addresses)
                    } catch {
                        print("⚠️ 이미지 \(index) 분석 실패: \(error.localizedDescription)")
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
        return DuplicateCounter.countDuplicates(allAddresses)
    }
    
    // MARK: - Private Helper Methods
    
    /// 테이블에서 주소를 추출합니다.
    private func extractAddressFromTables(
        _ tables: [DocumentObservation.Container.Table]
    ) async -> [String] {
        var allAddresses: [String] = []
            
        for table in tables {
            // "주소" 컬럼 찾기
            let columnAddresses = await AddressExtractor.extractAddressColumnFromTable(table)
                
            // 주소 패턴 추출
            let addresses = await AddressExtractor.extractAddressesFromText(
                columnAddresses.joined(separator: " ")
            )
                
            allAddresses.append(contentsOf: addresses)
        }
            
        return allAddresses
    }
    
    /// 텍스트에서 주소를 추출합니다.
    private func extractAddressFromText(_ text: String) async -> [String] {
        await AddressExtractor.extractAddressesFromText(text)
    }
    
    /// DocumentAnalysisResult에서 주소를 추출합니다 (병렬 처리용)
    private func extractAddressesFromAnalysisResult(
        _ result: DocumentAnalysisResult
    ) async -> [String] {
        var addresses: [String] = []
            
        if let tables = result.tables, !tables.isEmpty {
            // 테이블에서 추출
            addresses = await extractAddressFromTables(tables)
        } else {
            // 텍스트에서 추출
            addresses = await extractAddressFromText(result.recognizedText)
        }
            
        return addresses
    }
    
    // MARK: - Cleanup
    
    /// 리소스를 정리합니다.
    func cleanup() async {
        await documentDetector.cleanup()
    }
}
