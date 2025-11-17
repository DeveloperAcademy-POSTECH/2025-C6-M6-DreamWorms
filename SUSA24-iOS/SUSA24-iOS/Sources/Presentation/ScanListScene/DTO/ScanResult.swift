//
//  ScanResult.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation

/// 문서 분석 결과 모델
///
/// Vision Framework로 추출한 주소와 Geocode API로 검증된 좌표 정보를 담습니다.
struct ScanResult: Identifiable, Sendable {
    /// 고유 식별자
    let id: UUID

    /// 도로명 주소 (신주소)
    let roadAddress: String
    
    /// 지번 주소 (구주소)
    let jibunAddress: String

    /// 중복 횟수 (같은 주소가 여러 문서에서 발견된 경우)
    let duplicateCount: Int

    /// 원본 이미지 ID들 (어떤 사진에서 추출되었는지)
    let sourcePhotoIds: [UUID]
    
    /// 위도 (Geocode 검증 완료)
    let latitude: Double
    
    /// 경도 (Geocode 검증 완료)
    let longitude: Double
    
    /// 우선 표시할 주소 (신주소 우선, 없으면 구주소)
    var displayAddress: String {
        roadAddress.isEmpty ? jibunAddress : roadAddress
    }
    
    /// 신주소와 구주소 둘 다 있는지 확인
    var hasBothAddresses: Bool {
        !roadAddress.isEmpty && !jibunAddress.isEmpty
    }

    init(
        id: UUID = UUID(),
        roadAddress: String,
        jibunAddress: String,
        duplicateCount: Int,
        sourcePhotoIds: [UUID],
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.roadAddress = roadAddress
        self.jibunAddress = jibunAddress
        self.duplicateCount = duplicateCount
        self.sourcePhotoIds = sourcePhotoIds
        self.latitude = latitude
        self.longitude = longitude
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
