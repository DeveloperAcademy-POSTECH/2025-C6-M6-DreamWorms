//
//  AddressExtractionResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation
import Vision

/// 주소가 어떤 방식으로 추출되었는지 나타내는 타입
enum AddressExtractionSource: Sendable {
    case table /// 테이블 기반 추출
    case list /// 리스트 기반 추출
    case text /// 전체 텍스트 기반 추출
}

/// 주소 추출 최종 결과 모델
struct AddressExtractionResult: Sendable {
    /// [주소: 중복 횟수]
    var addresses: [String: Int] = [:]

    /// 테이블에서 추출된 주소 (pure list)
    var tableAddresses: [String] = []

    /// 리스트 구조에서 추출된 주소 (pure list)
    var listAddresses: [String] = []

    /// 텍스트 전체에서 추출된 주소 (pure list)
    var textAddresses: [String] = []

    /// 어떤 방식으로 추출되었는지
    var source: AddressExtractionSource = .text

    /// Vision 문서 객체 (bounding box 그릴 때 필요)
    var document: DocumentObservation.Container?

    /// Vision 테이블 객체 (bounding box 그릴 때 필요)
    var tables: [DocumentObservation.Container.Table] = []

    /// Vision 리스트 객체 (필요 시 활용)
    var lists: [DocumentObservation.Container.List] = []

    /// 추출 시각
    var extractedAt: Date = Date()

    // MARK: - Derived Values

    /// 중복 포함 전체 주소 개수
    var totalCount: Int {
        addresses.values.reduce(0, +)
    }

    /// 고유 주소 개수
    var uniqueCount: Int {
        addresses.count
    }

    /// 아무것도 없으면 true
    var isEmpty: Bool {
        addresses.isEmpty
    }

    /// 테이블 기반인가?
    var isTableExtraction: Bool {
        source == .table
    }

    /// 리스트 기반인가?
    var isListExtraction: Bool {
        source == .list
    }

    /// 텍스트 기반인가?
    var isTextExtraction: Bool {
        source == .text
    }
}
