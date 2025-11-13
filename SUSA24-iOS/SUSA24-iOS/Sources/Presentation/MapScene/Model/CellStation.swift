//
//  CellStation.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/12/25.
//

import Foundation

/// 기지국 데이터 모델
struct CellStation: Identifiable, Equatable, Sendable {
    /// 고유 식별자 (위도_경도 조합)
    let id: String
    
    /// 허가번호
    let permitNumber: Int
    
    /// 설치 장소
    let location: String
    
    /// 용도
    let purpose: String
    
    /// 위도 (십진법)
    let latitude: Double
    
    /// 경도 (십진법)
    let longitude: Double
    
    /// 방문 횟수 (동적 업데이트)
    var visitCount: Int
    
    /// 방문 여부
    var isVisited: Bool {
        visitCount > 0
    }
    
    // MARK: - Initializer
    
    init(
        permitNumber: Int,
        location: String,
        purpose: String,
        latitude: Double,
        longitude: Double,
        visitCount: Int = 0
    ) {
        self.id = "\(latitude)_\(longitude)"
        self.permitNumber = permitNumber
        self.location = location
        self.purpose = purpose
        self.latitude = latitude
        self.longitude = longitude
        self.visitCount = visitCount
    }
    
    // MARK: - Computed Properties
    
    /// markerType으로 변환
    var markerType: MarkerType {
        visitCount > 0 ? .cellWithCount(count: visitCount) : .cell(isVisited: false)
    }
}

// MARK: - DTO Conversion

extension CellStation {
    /// DTO로부터 도메인 모델 생성
    init(from dto: CellStationDTO) {
        self.init(
            permitNumber: dto.permitNumber,
            location: dto.location.trimmingCharacters(in: .whitespacesAndNewlines),
            purpose: dto.purpose,
            latitude: dto.latitudeDecimal,
            longitude: dto.longitudeDecimal
        )
    }
}
