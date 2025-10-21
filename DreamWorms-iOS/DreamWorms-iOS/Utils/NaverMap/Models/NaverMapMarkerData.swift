//
//  NaverMapMarkerData.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import CoreLocation
import Foundation

public struct NaverMapMarkerData: Identifiable, Sendable {
    public let id: UUID
    public let coordinate: CLLocationCoordinate2D
    public let title: String
    public let subtitle: String?
    public let frequency: Int
    public let groupIndex: Int?
    public let markerType: NaverMapDisplayMode
    public let timestamp: Date
    public let pinType: PinType
    
    public init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String? = nil,
        frequency: Int = 1,
        groupIndex: Int? = nil,
        markerType: NaverMapDisplayMode = .uniqueLocations,
        timestamp: Date = Date(),
        pinType: PinType = .custom
    ) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.frequency = frequency
        self.groupIndex = groupIndex
        self.markerType = markerType
        self.timestamp = timestamp
        self.pinType = pinType
    }
}

public extension NaverMapMarkerData {
    /// 빈도 표시
    var frequencyText: String? {
        frequency > 1 ? "(\(frequency))" : nil
    }
    
    /// 그룹 순서 표시
    var sequenceText: String? {
        guard let index = groupIndex else { return nil }
        return "\(index + 1)"
    }
    
    /// 마커 표시 제목 (빈도)
    var displayTitle: String {
        if let frequencyText {
            return "\(title) \(frequencyText)"
        }
        return title
    }
    
    /// 마커 표시 설명
    var displayDescription: String? {
        var components: [String] = []
        
        if let subtitle {
            components.append(subtitle)
        }
        
        if let sequenceText {
            components.append("순서: \(sequenceText)")
        }
        
        return components.isEmpty ? nil : components.joined(separator: " • ")
    }
    
    /// 좌표가 유효한지 확인
    var isValidLocation: Bool {
        coordinate.isValid
    }
    
    /// 포맷된 좌표 문자열
    var coordinateString: String {
        coordinate.coordinateString
    }
    
    // TODO: 추후 처리 방안 고안 필요
    /// 좌표 해시 키
    var coordinateKey: String {
        coordinate.coordinateKey
    }
}
