//
//  DocumentAnalysisResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import Foundation
import Vision

/// 문서 분석 결과를 나타내는 모델
struct DocumentAnalysisResult {
    /// 인식된 테이블들
    var tables: [DocumentObservation.Container.Table]?
    
    /// 인식된 문서 (테이블 + 텍스트 포함)
    var document: DocumentObservation.Container?
    
    /// 인식된 전체 텍스트
    var recognizedText: String = ""
    
    /// 분석 시각
    var analyzedAt: Date = Date()
    
    /// 원본 이미지 데이터
    var imageData: Data?
    
    /// 결과가 비어있는지 확인
    var isEmpty: Bool {
        recognizedText.isEmpty && tables?.isEmpty != false
    }
}
