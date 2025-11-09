//
//  AddressExtractionResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation
import Vision

/// 주소 추출
enum AddressExtractionSource: Sendable {
    case table
    case text
}

/// 주소 추출 결과를 나타내는 모델
struct AddressExtractionResult: Sendable {
    /// [주소: 중복 횟수]
    var addresses: [String: Int] = [:]
    
    /// 테이블에서 추출된 주소들
    var tableAddresses: [String] = []
    
    /// 텍스트에서 추출된 주소들
    var textAddresses: [String] = []
    
    /// 추출 소스 (테이블 or 텍스트)
    var extractionSource: AddressExtractionSource?
    
    /// 인식된 테이블들 (Bounding box 그리기용)
    /// Vision Framework의 Table 타입은 Sendable이 아니므로 주의
    var tables: [DocumentObservation.Container.Table]?
    
    /// 인식된 문서 (Bounding box 그리기용)
    /// Vision Framework의 Container 타입은 Sendable이 아니므로 주의
    var document: DocumentObservation.Container?
    
    /// 추출 시각
    var extractedAt: Date = Date()
    
    /// 추출된 총 주소 개수 (중복 포함)
    var totalCount: Int {
        addresses.values.reduce(0, +)
    }
    
    /// 고유 주소 개수
    var uniqueCount: Int {
        addresses.count
    }
    
    /// 결과가 비어있는지 확인
    var isEmpty: Bool {
        addresses.isEmpty
    }
    
    /// 테이블에서 추출했는지 여부
    var isTableExtraction: Bool {
        extractionSource == .table
    }
    
    /// 텍스트에서 추출했는지 여부
    var isTextExtraction: Bool {
        extractionSource == .text
    }
}
