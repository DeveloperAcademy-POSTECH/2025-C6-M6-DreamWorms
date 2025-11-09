//
//  ScanResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation

/// 문서 분석 결과 모델
///
/// Vision Framework로 추출한 주소 정보와 중복 횟수를 담는다.
struct ScanResult: Identifiable, Sendable {
    /// 고유 식별자
    let id: UUID
    
    /// 추출된 주소
    let address: String
    
    /// 중복 횟수 (같은 주소가 여러 문서에서 발견된 경우)
    let duplicateCount: Int
    
    /// 원본 이미지 ID들 (어떤 사진에서 추출되었는지)
    let sourcePhotoIds: [UUID]
    
    init(
        id: UUID = UUID(),
        address: String,
        duplicateCount: Int,
        sourcePhotoIds: [UUID]
    ) {
        self.id = id
        self.address = address
        self.duplicateCount = duplicateCount
        self.sourcePhotoIds = sourcePhotoIds
    }
}

// MARK: - Equatable

extension ScanResult: Equatable {
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable

extension ScanResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
