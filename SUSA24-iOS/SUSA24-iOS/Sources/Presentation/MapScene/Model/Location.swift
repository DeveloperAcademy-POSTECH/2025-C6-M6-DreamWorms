//
//  Location.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/3/25.
//

/// 위치 정보 모델

import Foundation

struct Location: Identifiable, Equatable, Sendable {
    var id: UUID
    var address: String
    var title: String?
    var note: String?
    var pointLatitude: Double
    var pointLongitude: Double
    var boxMinLatitude: Double?
    var boxMinLongitude: Double?
    var boxMaxLatitude: Double?
    var boxMaxLongitude: Double?
    var locationType: Int16
    var receivedAt: Date?
}
