//
//  CLLocationCoordinate2D.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation
import CoreLocation

// MARK: - CLLocationCoordinate2D Extensions

public extension CLLocationCoordinate2D {
    
    // MARK: - Validation
    
    /// 유효한 좌표인지 확인
    var isValid: Bool {
        latitude != 0.0 && longitude != 0.0 &&
        latitude >= -90.0 && latitude <= 90.0 &&
        longitude >= -180.0 && longitude <= 180.0
    }
    
    // MARK: - Formatting
    
    /// 좌표를 문자열로 변환
    var coordinateString: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }
    
    /// DMS (도분초) 형식으로 변환
    var dmsString: String {
        let latDMS = convertToDMS(latitude, isLatitude: true)
        let lngDMS = convertToDMS(longitude, isLatitude: false)
        return "\(latDMS), \(lngDMS)"
    }
    
    /// 좌표 해시 키 (중복 제거용)
    /// 소수점 5자리까지만 비교 (약 1m 정확도)
    var coordinateKey: String {
        let lat = Int(latitude * 100000)
        let lng = Int(longitude * 100000)
        return "\(lat),\(lng)"
    }
    
    /// 더 낮은 정밀도의 해시 키 (소수점 4자리, 약 10m 정확도)
    var roughCoordinateKey: String {
        let lat = Int(latitude * 10000)
        let lng = Int(longitude * 10000)
        return "\(lat),\(lng)"
    }
    
    // MARK: - Distance Calculations
    
    /// 다른 좌표까지의 거리 (미터)
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return from.distance(from: to)
    }
    
    /// 다른 좌표까지의 거리 (킬로미터)
    func distanceInKilometers(to coordinate: CLLocationCoordinate2D) -> Double {
        distance(to: coordinate) / 1000.0
    }
    
    /// 포맷된 거리 문자열
    func formattedDistance(to coordinate: CLLocationCoordinate2D) -> String {
        let dist = distance(to: coordinate)
        
        if dist < 1000 {
            return String(format: "%.0fm", dist)
        } else {
            return String(format: "%.1fkm", dist / 1000)
        }
    }
    
    // MARK: - Bearing Calculations
    
    /// 다른 좌표까지의 방위각 (도)
    func bearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let lat1 = latitude * .pi / 180
        let lat2 = coordinate.latitude * .pi / 180
        let deltaLon = (coordinate.longitude - longitude) * .pi / 180
        
        let x = sin(deltaLon) * cos(lat2)
        let y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        
        var bearing = atan2(x, y) * 180 / .pi
        if bearing < 0 {
            bearing += 360
        }
        
        return bearing
    }
    
    /// 방위각을 나침반 방향으로 변환
    func compassDirection(to coordinate: CLLocationCoordinate2D) -> String {
        let bearing = self.bearing(to: coordinate)
        
        switch bearing {
        case 0..<22.5, 337.5...360:
            return "북"
        case 22.5..<67.5:
            return "북동"
        case 67.5..<112.5:
            return "동"
        case 112.5..<157.5:
            return "남동"
        case 157.5..<202.5:
            return "남"
        case 202.5..<247.5:
            return "남서"
        case 247.5..<292.5:
            return "서"
        case 292.5..<337.5:
            return "북서"
        default:
            return "알 수 없음"
        }
    }
    
    // MARK: - Offset Calculations
    
    /// 오프셋을 적용한 새 좌표
    func offsetBy(meters: Double, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6371000.0 // 미터
        
        let angularDistance = meters / earthRadius
        let bearingRadians = bearing * .pi / 180
        
        let lat1 = latitude * .pi / 180
        let lon1 = longitude * .pi / 180
        
        let lat2 = asin(sin(lat1) * cos(angularDistance) +
                       cos(lat1) * sin(angularDistance) * cos(bearingRadians))
        
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(angularDistance) * cos(lat1),
                                cos(angularDistance) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }
    
    // MARK: - Private Helpers
    
    private func convertToDMS(_ coordinate: Double, isLatitude: Bool) -> String {
        let absolute = abs(coordinate)
        let degrees = Int(absolute)
        let minutesNotTruncated = (absolute - Double(degrees)) * 60
        let minutes = Int(minutesNotTruncated)
        let seconds = (minutesNotTruncated - Double(minutes)) * 60
        
        let direction: String
        if isLatitude {
            direction = coordinate >= 0 ? "N" : "S"
        } else {
            direction = coordinate >= 0 ? "E" : "W"
        }
        
        return String(format: "%d°%d'%.1f\"%@", degrees, minutes, seconds, direction)
    }
}

// MARK: - Equatable

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Hashable

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
