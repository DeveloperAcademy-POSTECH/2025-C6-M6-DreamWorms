//
//  Evidence.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/20/25.
//

import Foundation

/// 증거 데이터 모델 (UI 테스트용)
struct Evidence: Identifiable {
    let id: UUID
    let evidenceType: EvidenceType
    let displayName: String
    let recordedLatitude: Double
    let recordedLongitude: Double
    let recordedAt: Date
    
    init(
        id: UUID = UUID(),
        evidenceType: EvidenceType,
        displayName: String,
        recordedLatitude: Double,
        recordedLongitude: Double,
        recordedAt: Date
    ) {
        self.id = id
        self.evidenceType = evidenceType
        self.displayName = displayName
        self.recordedLatitude = recordedLatitude
        self.recordedLongitude = recordedLongitude
        self.recordedAt = recordedAt
    }
}

// MARK: - Evidence Type

enum EvidenceType {
    case cellTower // 기지국
    case cardUsage // 카드내역
    case vehicle // 차량정보
    case crimeScene // 범행장소
}

// MARK: - Mock Data (10월 12~14일)

extension Evidence {
    static let mockData: [Evidence] = {
        var allData: [Evidence] = []
        let calendar = Calendar.current
        
        // ========================================
        // 10월 12일 (토) - 주말
        // ========================================
        if let day12 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 12)) {
            allData += [
                // 집에서 시작
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day12.addingTimeInterval(8 * 3600) // 08:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day12.addingTimeInterval(10 * 3600) // 10:00
                ),
                
                // 시내로 외출
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day12.addingTimeInterval(12 * 3600) // 12:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 칠성로 49, (대흥동)",
                    recordedLatitude: 36.039658,
                    recordedLongitude: 129.364425,
                    recordedAt: day12.addingTimeInterval(13 * 3600 + 30 * 60) // 13:30
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙상가길 16, (대흥동)",
                    recordedLatitude: 36.039722,
                    recordedLongitude: 129.367222,
                    recordedAt: day12.addingTimeInterval(15 * 3600) // 15:00
                ),
                
                // 집 복귀
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day12.addingTimeInterval(17 * 3600) // 17:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day12.addingTimeInterval(20 * 3600) // 20:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day12.addingTimeInterval(23 * 3600) // 23:00
                ),
            ]
        }
        
        // ========================================
        // 10월 13일 (일) - 주말
        // ========================================
        if let day13 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 13)) {
            allData += [
                // 집에서 시작
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day13.addingTimeInterval(9 * 3600) // 09:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day13.addingTimeInterval(11 * 3600) // 11:00
                ),
                
                // 점심 외출
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 칠성로 49, (대흥동)",
                    recordedLatitude: 36.039658,
                    recordedLongitude: 129.364425,
                    recordedAt: day13.addingTimeInterval(12 * 3600 + 30 * 60) // 12:30
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 칠성로 49, (대흥동)",
                    recordedLatitude: 36.039658,
                    recordedLongitude: 129.364425,
                    recordedAt: day13.addingTimeInterval(13 * 3600) // 13:00
                ),
                
                // 시내 이동
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day13.addingTimeInterval(14 * 3600) // 14:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중흥로 232, (죽도동)",
                    recordedLatitude: 36.034722,
                    recordedLongitude: 129.364722,
                    recordedAt: day13.addingTimeInterval(16 * 3600) // 16:00
                ),
                
                // 집 복귀
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 시청로 1, (대잠동)",
                    recordedLatitude: 36.033055,
                    recordedLongitude: 129.363888,
                    recordedAt: day13.addingTimeInterval(17 * 3600 + 30 * 60) // 17:30
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day13.addingTimeInterval(18 * 3600) // 18:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day13.addingTimeInterval(21 * 3600) // 21:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day13.addingTimeInterval(23 * 3600 + 30 * 60) // 23:30
                ),
            ]
        }
        
        // ========================================
        // 10월 14일 (월) - 평일 (출근)
        // ========================================
        if let day14 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 14)) {
            allData += [
                // 새벽 집
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day14.addingTimeInterval(0 * 3600) // 00:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day14.addingTimeInterval(6 * 3600 + 50 * 60) // 06:50
                ),
                
                // 출근
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 상공로 3, (상도동)",
                    recordedLatitude: 36.031388,
                    recordedLongitude: 129.363055,
                    recordedAt: day14.addingTimeInterval(7 * 3600 + 5 * 60) // 07:05
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 시청로 1, (대잠동)",
                    recordedLatitude: 36.033055,
                    recordedLongitude: 129.363888,
                    recordedAt: day14.addingTimeInterval(7 * 3600 + 10 * 60) // 07:10
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중흥로 232, (죽도동)",
                    recordedLatitude: 36.034722,
                    recordedLongitude: 129.364722,
                    recordedAt: day14.addingTimeInterval(7 * 3600 + 15 * 60) // 07:15
                ),
                
                // 회사 도착
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day14.addingTimeInterval(7 * 3600 + 30 * 60) // 07:30
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day14.addingTimeInterval(9 * 3600) // 09:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day14.addingTimeInterval(11 * 3600 + 50 * 60) // 11:50
                ),
                
                // 점심
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 칠성로 49, (대흥동)",
                    recordedLatitude: 36.039658,
                    recordedLongitude: 129.364425,
                    recordedAt: day14.addingTimeInterval(12 * 3600) // 12:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 칠성로 49, (대흥동)",
                    recordedLatitude: 36.039658,
                    recordedLongitude: 129.364425,
                    recordedAt: day14.addingTimeInterval(12 * 3600 + 40 * 60) // 12:40
                ),
                
                // 회사 복귀
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day14.addingTimeInterval(13 * 3600) // 13:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day14.addingTimeInterval(15 * 3600) // 15:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙로 325, (덕수동)",
                    recordedLatitude: 36.038161,
                    recordedLongitude: 129.367805,
                    recordedAt: day14.addingTimeInterval(17 * 3600 + 50 * 60) // 17:50
                ),
                
                // 퇴근
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 중앙상가길 16, (대흥동)",
                    recordedLatitude: 36.039722,
                    recordedLongitude: 129.367222,
                    recordedAt: day14.addingTimeInterval(18 * 3600) // 18:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 북구 포스코대로 289, (죽도동)",
                    recordedLatitude: 36.036388,
                    recordedLongitude: 129.365555,
                    recordedAt: day14.addingTimeInterval(18 * 3600 + 10 * 60) // 18:10
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 시청로 1, (대잠동)",
                    recordedLatitude: 36.033055,
                    recordedLongitude: 129.363888,
                    recordedAt: day14.addingTimeInterval(18 * 3600 + 20 * 60) // 18:20
                ),
                
                // 집 도착
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day14.addingTimeInterval(18 * 3600 + 30 * 60) // 18:30
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day14.addingTimeInterval(20 * 3600) // 20:00
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day14.addingTimeInterval(22 * 3600 + 30 * 60) // 22:30
                ),
                Evidence(
                    evidenceType: .cellTower,
                    displayName: "경상북도 포항시 남구 형산강북로 136, (상도동)",
                    recordedLatitude: 36.02975,
                    recordedLongitude: 129.362111,
                    recordedAt: day14.addingTimeInterval(23 * 3600 + 55 * 60) // 23:55
                ),
            ]
        }
        
        return allData
    }()
}
