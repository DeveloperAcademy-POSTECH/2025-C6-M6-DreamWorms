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
    
    /// 텍스트에서 추출된 주소들
    var textAddresses: [String] = []
    
    /// 현재 분석 상태
    var isAnalyzing: Bool = false
    
    /// 마지막 분석 결과
    var lastResult: AddressExtractionResult?
    
    /// 마지막 에러
    var lastError: VisionAnalysisError?
    
    // MARK: - Public Methods
    
    /// 이미지 데이터에서 한국 주소를 추출합니다.
    /// - Parameter imageData: 분석할 이미지 데이터
    func recognizeAddress(from imageData: Data) async {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        do {
            // 1. 문서 분석 (테이블 + 텍스트)
            let analysisResult = try await DocumentAnalyzer.analyzeDocument(from: imageData)
            
            var allAddresses: [String] = []
            
            // 2. 테이블이 있으면 테이블에서만 추출 (중복 방지)
            if let tables = analysisResult.tables, !tables.isEmpty {
                let extractedTableAddresses = await extractAddressFromTable(tables)
                allAddresses.append(contentsOf: extractedTableAddresses)
                
                await MainActor.run {
                    self.tableAddresses = extractedTableAddresses
                }
            } else {
                // 3. 테이블이 없으면 텍스트에서 추출
                let extractedTextAddresses = await extractAddressFromText(analysisResult.recognizedText)
                allAddresses.append(contentsOf: extractedTextAddresses)
                
                await MainActor.run {
                    self.textAddresses = extractedTextAddresses
                }
            }
            
            // 4. 중복 제거 및 카운팅
            let countedAddresses = DuplicateCounter.countDuplicates(allAddresses)
            
            // 5. 상태 업데이트
            await MainActor.run {
                self.addresses = countedAddresses
                self.lastError = nil
                
                // 추출 소스 결정
                let source: AddressExtractionSource = !self.tableAddresses.isEmpty ? .table : .text
                
                self.lastResult = AddressExtractionResult(
                    addresses: countedAddresses,
                    tableAddresses: self.tableAddresses,
                    textAddresses: self.textAddresses,
                    extractionSource: source,
                    tables: analysisResult.tables,
                    document: analysisResult.document,
                    extractedAt: Date()
                )
            }
            
        } catch let error as VisionAnalysisError {
            await MainActor.run {
                self.lastError = error
            }
        } catch {
            await MainActor.run {
                self.lastError = .imageProcessingFailed(error.localizedDescription)
                print("예상치 못한 에러: \(error.localizedDescription)")
            }
        }
    }
    
    /// 주소 결과를 초기화합니다.
    func clearResults() {
        addresses = [:]
        tableAddresses = []
        textAddresses = []
        lastResult = nil
        lastError = nil
    }
    
    // MARK: - Private Methods
    
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
    
    // MARK: - Statistics
    
    /// 총 추출된 주소 개수 (중복 포함)
    var totalCount: Int {
        addresses.values.reduce(0, +)
    }
    
    /// 고유 주소 개수
    var uniqueCount: Int {
        addresses.count
    }
    
    /// 상위 N개 주소를 반환합니다.
    func topAddresses(count: Int = 10) -> [(address: String, count: Int)] {
        DuplicateCounter.topAddresses(addresses, topN: count)
    }
    
    /// 주소 결과가 비어있는지 확인합니다.
    var isEmpty: Bool {
        addresses.isEmpty
    }
}
