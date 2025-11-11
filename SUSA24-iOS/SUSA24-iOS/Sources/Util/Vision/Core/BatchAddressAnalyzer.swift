//
//  BatchAddressAnalyzer.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation
import Vision

/// 여러 이미지를 배치로 분석하는 Actor
///
/// ## 역할
/// - ScanLoadFeature에서 사용하는 배치 처리 전용
/// - Thread-safe한 순차 분석 담당
/// - 진행률 추적 기능 제공
///
/// ## 사용 예시
/// ```swift
/// let analyzer = BatchAddressAnalyzer()
/// let result = await analyzer.analyzePhotos(photos) { progress in
///     print("진행률: \(progress.currentIndex)/\(progress.totalCount)")
/// }
/// ```
final class BatchAddressAnalyzer: Sendable {
    
    /// 분석 진행 상태를 나타내는 구조체
    struct AnalysisProgress {
        let currentIndex: Int
        let totalCount: Int
        let currentPhoto: CapturedPhoto
        
        var percentage: Double {
            guard totalCount > 0 else { return 0 }
            return Double(currentIndex) / Double(totalCount)
        }
    }
    
    /// 분석 결과를 나타내는 구조체
    struct BatchAnalysisResult {
        /// 병합된 주소와 중복 횟수 [주소: 개수]
        let addresses: [String: Int]
        
        /// 성공한 이미지 개수
        let successCount: Int
        
        /// 실패한 이미지 개수
        let failedCount: Int
        
        /// 전체 이미지 개수
        let totalCount: Int
        
        /// 분석 완료 여부
        var isCompleted: Bool {
            successCount + failedCount == totalCount
        }
        
        /// 결과가 비어있는지 확인
        var isEmpty: Bool {
            addresses.isEmpty
        }
    }
    
    // MARK: - Public Methods
    
    /// 여러 이미지를 순차적으로 분석합니다.
    ///
    /// - Parameters:
    ///   - photos: 분석할 사진 배열
    ///   - progressHandler: 진행 상태 콜백 (MainActor에서 실행됨)
    /// - Returns: 배치 분석 결과
    func analyzePhotos(
        _ photos: [CapturedPhoto],
        progressHandler: (@MainActor (AnalysisProgress) async -> Void)? = nil
    ) async -> BatchAnalysisResult {
        
        guard !photos.isEmpty else {
            return BatchAnalysisResult(
                addresses: [:],
                successCount: 0,
                failedCount: 0,
                totalCount: 0
            )
        }
        
        var mergedAddresses: [String: Int] = [:]
        var successCount = 0
        var failedCount = 0
        
        // 순차적으로 각 이미지 분석
        for (index, photo) in photos.enumerated() {
            
            // 진행 상태 알림
            if let progressHandler = progressHandler {
                let progress = AnalysisProgress(
                    currentIndex: index + 1,
                    totalCount: photos.count,
                    currentPhoto: photo
                )
                await progressHandler(progress)
            }
            
            // 이미지 분석
            do {
                let addresses = try await analyzeSinglePhoto(photo)
                
                // 결과 병합
                mergedAddresses = DuplicateCounter.mergeDictionaries(mergedAddresses, addresses)
                successCount += 1
                
            } catch {
                // 에러 처리: 스킵 후 계속 (기본)
                failedCount += 1
            }
        }
        
        return BatchAnalysisResult(
            addresses: mergedAddresses,
            successCount: successCount,
            failedCount: failedCount,
            totalCount: photos.count
        )
    }
    
    // MARK: - Private Methods
    
    /// 단일 이미지를 분석하여 주소를 추출합니다.
    /// - Parameter photo: 분석할 사진
    /// - Returns: [주소: 개수] 딕셔너리
    /// - Throws: 분석 실패 시 VisionAnalysisError
    private func analyzeSinglePhoto(_ photo: CapturedPhoto) async throws -> [String: Int] {
        // 1. 문서 분석 (테이블 + 텍스트)
        let analysisResult = try await DocumentAnalyzer.analyzeDocument(from: photo.data)
        
        var allAddresses: [String] = []
        
        // 2. 테이블이 있으면 테이블에서만 추출 (중복 방지)
        if let tables = analysisResult.tables, !tables.isEmpty {
            let extractedTableAddresses = await extractAddressFromTable(tables)
            allAddresses.append(contentsOf: extractedTableAddresses)
        } else {
            // 3. 테이블이 없으면 텍스트에서 추출
            let extractedTextAddresses = await extractAddressFromText(analysisResult.recognizedText)
            allAddresses.append(contentsOf: extractedTextAddresses)
        }
        
        // 4. 중복 제거 및 카운팅
        return DuplicateCounter.countDuplicates(allAddresses)
    }
    
    /// 테이블에서 주소를 추출합니다.
    private func extractAddressFromTable(_ tables: [DocumentObservation.Container.Table]) async -> [String] {
        var allAddresses: [String] = []
        
        for table in tables {
            let addresses = await AddressExtractor.extractAddressColumnFromTable(table)
            allAddresses.append(contentsOf: addresses)
        }
        
        return await AddressExtractor.extractAddressesFromText(allAddresses.joined(separator: " "))
    }
    
    /// 텍스트에서 주소를 추출합니다.
    private func extractAddressFromText(_ text: String) async -> [String] {
        await AddressExtractor.extractAddressesFromText(text)
    }
}
