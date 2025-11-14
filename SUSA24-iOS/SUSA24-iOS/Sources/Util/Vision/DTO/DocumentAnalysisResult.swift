//
//  DocumentAnalysisResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation
import Vision

/// Vision 문서 분석 결과
struct DocumentAnalysisResult: Sendable {
    /// 인식된 테이블들
    var tables: [DocumentObservation.Container.Table] = []

    /// 인식된 리스트 블록들
    var lists: [DocumentObservation.Container.List] = []

    /// 전체 인식 텍스트
    var recognizedText: String = ""

    /// 원본 Document Container
    var document: DocumentObservation.Container?

    /// 분석 시각
    var analyzedAt: Date = Date()

    /// 원본 이미지 (옵션)
    var imageData: Data?

    /// 결과 존재 여부
    var isEmpty: Bool {
        tables.isEmpty && lists.isEmpty && recognizedText.isEmpty
    }
}
