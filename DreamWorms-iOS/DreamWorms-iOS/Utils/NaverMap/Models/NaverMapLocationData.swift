//
//  NaverMapLocationData.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation
import CoreLocation

// MARK: - Location Data Model

public struct NaverMapLocationData: Identifiable, Sendable {
    public let id: UUID
    public let coordinate: CLLocationCoordinate2D
    public let timestamp: Date
    public let address: String
    public let additionalInfo: [String: String]
    
    public init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        timestamp: Date = Date(),
        address: String = "",
        additionalInfo: [String: String] = [:]
    ) {
        self.id = id
        self.coordinate = coordinate
        self.timestamp = timestamp
        self.address = address
        self.additionalInfo = additionalInfo
    }
}

// MARK: - Computed Properties

public extension NaverMapLocationData {
    /// 포맷된 타임스탬프
    var formattedTimestamp: String {
        timestamp.formattedTimestamp
    }
    
    /// 좌표 해시 키 (중복 제거용)
    var coordinateKey: String {
        coordinate.coordinateKey
    }
    
    /// 좌표가 유효한지 확인
    var isValidLocation: Bool {
        coordinate.isValid
    }
    
    /// 상대적 시간 표시
    var relativeTime: String {
        timestamp.relativeTimeString
    }
}

// MARK: - Methods

public extension NaverMapLocationData {
    /// 다른 위치까지의 거리
    func distance(to other: NaverMapLocationData) -> CLLocationDistance {
        coordinate.distance(to: other.coordinate)
    }
    
    /// 포맷된 거리 문자열
    func formattedDistance(to other: NaverMapLocationData) -> String {
        coordinate.formattedDistance(to: other.coordinate)
    }
    
    /// 다른 위치까지의 방위각
    func bearing(to other: NaverMapLocationData) -> Double {
        coordinate.bearing(to: other.coordinate)
    }
    
    /// 다른 위치까지의 나침반 방향
    func compassDirection(to other: NaverMapLocationData) -> String {
        coordinate.compassDirection(to: other.coordinate)
    }
}
