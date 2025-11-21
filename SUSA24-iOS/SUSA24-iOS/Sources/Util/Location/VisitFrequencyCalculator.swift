//
//  VisitFrequencyCalculator.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/16/25.
//

import Foundation

// MARK: - Visit Frequency Calculator

/// 위치 데이터의 방문 빈도를 다양한 방식으로 계산하는 유틸리티입니다.
///
/// **방문빈도 (연속 그룹 빈도)**
/// - 연속된 동일 위치는 1회로 계산
/// - 다른 위치를 거쳐 다시 돌아오면 새로운 방문으로 카운트
/// - 예시: A-A-A-B-B-A-C-C-B → A(2회), B(2회), C(1회)
///
/// **체류빈도 (총 체류시간)**
/// - 모든 위치 데이터를 단순 카운트
/// - 예시: A-A-A-B-B-A-C-C-B → A(4회), B(3회), C(2회)
enum VisitFrequencyCalculator {
    // MARK: - 1. 방문빈도 (연속 그룹 빈도)
    
    /// 좌표 기반 방문 빈도를 계산합니다. (연속 그룹 방식)
    ///
    /// 연속된 동일 위치는 1회로 계산하고, 다른 위치를 거쳐 다시 오면 새로운 방문으로 카운트합니다.
    ///
    /// - Parameters:
    ///   - locations: 계산 대상 위치 데이터 배열
    ///   - precision: 좌표 정밀도 (소수점 자릿수, 기본값 6)
    /// - Returns: 좌표 키와 (위도, 경도, 방문횟수) 매핑
    ///
    /// **예시:**
    /// ```
    /// A-A-A-B-B-A-C-C-B
    /// → A: 2회, B: 2회, C: 1회
    /// ```
    ///  TAENI : 확인 후 프린트문을 지워주세요
    static func calculateVisitFrequencyByCoordinate(
        _ locations: [Location],
        precision: Int = 6
    ) -> [String: (latitude: Double, longitude: Double, count: Int)] {
        // 1. 기지국만 필터링 후 시간순 정렬
        let cellLocations = locations
            .filter { $0.locationType == 2 }
            .sorted { ($0.receivedAt ?? Date.distantPast) < ($1.receivedAt ?? Date.distantPast) }
                
        // 2. 연속 방문 감지
        var groups: [String: (latitude: Double, longitude: Double, count: Int)] = [:]
        var lastKey: String?
        var consecutiveCount = 0
        var visitGroupCount = 0
        
        for location in cellLocations {
            let latitude = location.pointLatitude
            let longitude = location.pointLongitude
            guard latitude != 0, longitude != 0 else { continue }
            
            let key = coordinateKey(latitude: latitude, longitude: longitude, precision: precision)
            
            // 핵심: 이전 위치와 다를 때만 카운트 증가
            if key != lastKey {
                if lastKey != nil {
                    visitGroupCount += 1
                }
                
                var entry = groups[key] ?? (latitude, longitude, 0)
                entry.count += 1
                groups[key] = entry
                lastKey = key
                consecutiveCount = 1
            } else {
                consecutiveCount += 1
            }
        }
        
        return groups
    }
    
    /// 주소 기반 방문 빈도를 계산합니다. (연속 그룹 방식)
    ///
    /// 연속된 동일 주소는 1회로 계산하고, 다른 주소를 거쳐 다시 오면 새로운 방문으로 카운트합니다.
    ///
    /// - Parameter locations: 계산 대상 위치 데이터 배열
    /// - Returns: 주소와 방문 횟수 매핑
    ///
    /// **예시:**
    /// ```
    /// 집-집-집-회사-회사-집-카페-카페-회사
    /// → 집: 2회, 회사: 2회, 카페: 1회
    /// ```
    static func calculateVisitFrequencyByAddress(_ locations: [Location]) -> [String: Int] {
        // 1. 기지국만 필터링 후 시간순 정렬
        let cellLocations = locations
            .filter { $0.locationType == 2 }
            .sorted { ($0.receivedAt ?? Date.distantPast) < ($1.receivedAt ?? Date.distantPast) }
        
        // 2. 연속 방문 감지
        var addressCounts: [String: Int] = [:]
        var lastAddress: String?
        
        for location in cellLocations {
            let address = location.address.isEmpty ? "기지국 주소" : location.address
            
            // 핵심: 이전 주소와 다를 때만 카운트 증가
            if address != lastAddress {
                addressCounts[address, default: 0] += 1
                lastAddress = address
            }
        }
        
        return addressCounts
    }
    
    // MARK: - 2. 체류빈도 (총 체류시간)
    
    /// 좌표 기반 체류 빈도를 계산합니다. (총 카운트 방식)
    ///
    /// 모든 위치 데이터를 단순 카운트하여 총 체류 시간을 추정합니다.
    ///
    /// - Parameters:
    ///   - locations: 계산 대상 위치 데이터 배열
    ///   - precision: 좌표 정밀도 (소수점 자릿수, 기본값 6)
    /// - Returns: 좌표 키와 (위도, 경도, 체류횟수) 매핑
    ///
    /// **예시:**
    /// ```
    /// A-A-A-B-B-A-C-C-B
    /// → A: 4회, B: 3회, C: 2회
    /// ```
    static func calculateStayFrequencyByCoordinate(
        _ locations: [Location],
        precision: Int = 6
    ) -> [String: (latitude: Double, longitude: Double, count: Int)] {
        // 1. 기지국만 필터링
        let cellLocations = locations.filter { $0.locationType == 2 }
        
        // 2. 단순 그룹화 (모든 데이터 카운트)
        var groups: [String: (latitude: Double, longitude: Double, count: Int)] = [:]
        
        for location in cellLocations {
            let latitude = location.pointLatitude
            let longitude = location.pointLongitude
            guard latitude != 0, longitude != 0 else { continue }
            
            let key = coordinateKey(latitude: latitude, longitude: longitude, precision: precision)
            var entry = groups[key] ?? (latitude, longitude, 0)
            entry.count += 1
            groups[key] = entry
        }
        
        return groups
    }
    
    /// 주소 기반 체류 빈도를 계산합니다. (총 카운트 방식)
    ///
    /// 모든 위치 데이터를 단순 카운트하여 총 체류 시간을 추정합니다.
    ///
    /// - Parameter locations: 계산 대상 위치 데이터 배열
    /// - Returns: 주소와 체류 횟수 매핑
    ///
    /// **예시:**
    /// ```
    /// 집-집-집-회사-회사-집-카페-카페-회사
    /// → 집: 4회, 회사: 3회, 카페: 2회
    /// ```
    static func calculateStayFrequencyByAddress(_ locations: [Location]) -> [String: Int] {
        // 1. 기지국만 필터링
        let cellLocations = locations.filter { $0.locationType == 2 }
        
        // 2. 단순 그룹화 (모든 데이터 카운트)
        var addressCounts: [String: Int] = [:]
        
        for location in cellLocations {
            let address = location.address.isEmpty ? "기지국 주소" : location.address
            addressCounts[address, default: 0] += 1
        }
        
        return addressCounts
    }
    
    // MARK: - Private Helpers
    
    /// 좌표를 문자열 키로 변환합니다.
    private static func coordinateKey(
        latitude: Double,
        longitude: Double,
        precision: Int
    ) -> String {
        let format = "%.\(precision)f"
        let latString = String(format: format, latitude)
        let lngString = String(format: format, longitude)
        return "\(latString)_\(lngString)"
    }
}

// MARK: - Array<Location> Extension

extension Array<Location> {
    // MARK: - 방문빈도 (연속 그룹 빈도)
    
    /// 좌표 기반 방문 빈도를 계산합니다. (연속 그룹 방식)
    ///
    /// 연속된 동일 위치는 1회로 계산하고, 다른 위치를 거쳐 다시 오면 새로운 방문으로 카운트합니다.
    ///
    /// - Parameter precision: 좌표 정밀도 (소수점 자릿수, 기본값 6)
    /// - Returns: 좌표 키와 (위도, 경도, 방문횟수) 매핑
    func visitFrequencyByCoordinate(
        precision: Int = 6
    ) -> [String: (latitude: Double, longitude: Double, count: Int)] {
        VisitFrequencyCalculator.calculateVisitFrequencyByCoordinate(self, precision: precision)
    }
    
    /// 주소 기반 방문 빈도를 계산합니다. (연속 그룹 방식)
    ///
    /// 연속된 동일 주소는 1회로 계산하고, 다른 주소를 거쳐 다시 오면 새로운 방문으로 카운트합니다.
    ///
    /// - Returns: 주소와 방문 횟수 매핑
    func visitFrequencyByAddress() -> [String: Int] {
        VisitFrequencyCalculator.calculateVisitFrequencyByAddress(self)
    }
    
    // MARK: - 체류빈도 (총 체류시간)
    
    /// 좌표 기반 체류 빈도를 계산합니다. (총 카운트 방식)
    ///
    /// 모든 위치 데이터를 단순 카운트하여 총 체류 시간을 추정합니다.
    ///
    /// - Parameter precision: 좌표 정밀도 (소수점 자릿수, 기본값 6)
    /// - Returns: 좌표 키와 (위도, 경도, 체류횟수) 매핑
    func stayFrequencyByCoordinate(
        precision: Int = 6
    ) -> [String: (latitude: Double, longitude: Double, count: Int)] {
        VisitFrequencyCalculator.calculateStayFrequencyByCoordinate(self, precision: precision)
    }
    
    /// 주소 기반 체류 빈도를 계산합니다. (총 카운트 방식)
    ///
    /// 모든 위치 데이터를 단순 카운트하여 총 체류 시간을 추정합니다.
    ///
    /// - Returns: 주소와 체류 횟수 매핑
    func stayFrequencyByAddress() -> [String: Int] {
        VisitFrequencyCalculator.calculateStayFrequencyByAddress(self)
    }
}
