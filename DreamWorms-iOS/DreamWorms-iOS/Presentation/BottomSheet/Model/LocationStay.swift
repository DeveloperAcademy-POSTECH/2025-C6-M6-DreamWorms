//  LocationStay.swift
//  DreamWorms-iOS

import Foundation

/// 위치별 체류 정보
///
/// 역할: 연속된 같은 위치의 시작~종료 시간 표현
struct LocationStay: Identifiable {
    let id: UUID
    let address: String
    let startTime: Date
    let endTime: Date
    let locations: [CaseLocation] // 원본 데이터 참조
    
    init(
        id: UUID = UUID(),
        address: String,
        startTime: Date,
        endTime: Date,
        locations: [CaseLocation]
    ) {
        self.id = id
        self.address = address
        self.startTime = startTime
        self.endTime = endTime
        self.locations = locations
    }
    
    /// 체류 시간 (초 단위)
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    /// 현재 진행 중인지 여부 (마지막 데이터가 현재로부터 10분 이내)
    var isOngoing: Bool {
        Date().timeIntervalSince(endTime) < 600 // 10분
    }
}

// MARK: - CaseLocation 배열 → LocationStay 배열 변환

extension LocationStay {
    /// CaseLocation 배열을 LocationStay 배열로 변환
    /// - Parameter locations: 시간순 정렬된 CaseLocation 배열
    /// - Returns: 연속된 같은 위치를 그룹화한 LocationStay 배열
    static func groupByConsecutiveLocation(from locations: [CaseLocation]) -> [LocationStay] {
        guard !locations.isEmpty else { return [] }
        
        // 1. 시간순 정렬 (오래된 순서부터)
        let sortedLocations = locations
            .filter { $0.address != nil } // address 없는 건 제외
            .sorted { $0.receivedAt < $1.receivedAt }
        
        guard !sortedLocations.isEmpty else { return [] }
        
        var stays: [LocationStay] = []
        var currentGroup: [CaseLocation] = [sortedLocations[0]]
        var currentAddress = sortedLocations[0].address!
        
        // 2. 연속된 같은 주소끼리 그룹핑
        for i in 1 ..< sortedLocations.count {
            let location = sortedLocations[i]
            
            // 같은 주소면 현재 그룹에 추가
            if location.address == currentAddress {
                currentGroup.append(location)
            } else {
                // 다른 주소면 이전 그룹 저장하고 새 그룹 시작
                if let stay = createStay(from: currentGroup, address: currentAddress) {
                    stays.append(stay)
                }
                
                currentGroup = [location]
                currentAddress = location.address!
            }
        }
        
        // 3. 마지막 그룹 저장
        if let stay = createStay(from: currentGroup, address: currentAddress) {
            stays.append(stay)
        }
        
        return stays
    }
    
    /// CaseLocation 그룹에서 LocationStay 생성
    private static func createStay(
        from group: [CaseLocation],
        address: String
    ) -> LocationStay? {
        guard !group.isEmpty,
              let startTime = group.first?.receivedAt,
              let endTime = group.last?.receivedAt
        else {
            return nil
        }
        
        return LocationStay(
            address: address,
            startTime: startTime,
            endTime: endTime,
            locations: group
        )
    }
}
