//
//  LocationMockLoader.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/3/25.
//

import CoreData
import Foundation

// MARK: - (기존) 목데이터 가져오는 방식 주석

// private nonisolated struct WeeklyCellLocationDTO: Decodable, Sendable {
//    let address: String
//    let receivedAt: Date
//    let pointLatitude: Double
//    let pointLongitude: Double
//
//    enum CodingKeys: String, CodingKey {
//        case address
//        case receivedAt
//        case pointLatitude
//        case pointLongitude
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.address = try container.decode(String.self, forKey: .address)
//        self.pointLatitude = try container.decode(Double.self, forKey: .pointLatitude)
//        self.pointLongitude = try container.decode(Double.self, forKey: .pointLongitude)
//
//        let dateString = try container.decode(String.self, forKey: .receivedAt)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter.locale = Locale(identifier: "ko_KR")
//        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
//        guard let date = formatter.date(from: dateString) else {
//            throw DecodingError.dataCorruptedError(
//                forKey: .receivedAt,
//                in: container,
//                debugDescription: "Invalid date format: \(dateString). Expected yyyy-MM-dd'T'HH:mm:ss"
//            )
//        }
//        self.receivedAt = date
//    }
// }

// MARK: - (기존) 목데이터 가져오는 방식 주석

// static func loadWeeklyCellSampleAsync() async throws -> [Location] {
//    let dtos: [WeeklyCellLocationDTO] = try await JSONLoader.loadAsync(
//        "weekly_cell_sample.json",
//        as: [WeeklyCellLocationDTO].self
//    )
//    return dtos.map { dto in
//        Location(
//            id: UUID(),
//            address: dto.address,
//            title: nil,
//            note: nil,
//            pointLatitude: dto.pointLatitude,
//            pointLongitude: dto.pointLongitude,
//            boxMinLatitude: nil,
//            boxMinLongitude: nil,
//            boxMaxLatitude: nil,
//            boxMaxLongitude: nil,
//            locationType: Int16.random(in: 0 ... 3),   // ← 랜덤 타입 (비활성화 이유)
//            colorType: Int16.random(in: 0 ... 6),
//            receivedAt: dto.receivedAt
//        )
//    }
// }
//
// static func loadAndSaveToCoreData(caseId: UUID, context: NSManagedObjectContext) async throws {
//    let locations = try await loadWeeklyCellSampleAsync()
//    let repository = LocationRepository(context: context)
//    try await repository.createLocations(data: locations, caseId: caseId)
// }

// private nonisolated struct CellLogRootDTO: Decodable, Sendable {
//    let locations: [CellLogDTO]
// }
//
// private nonisolated struct CellLogDTO: Decodable, Sendable {
//    let timestamp: String
//    let message: String
//    let address: String
//    let notes: String?
// }
//
// enum LocationMockLoader {
//    /// cell_logs.json → [Location] 변환
//    /// - timestamp 파싱
//    /// - 주소 → 네이버 지오코딩 변환
//    /// - 실패 시 fallback (0,0)
//    /// - LocationType = 2(cell) 고정
//    static func loadCellLogSampleWithGeocode() async throws -> [Location] {
//        let root: CellLogRootDTO = try await JSONLoader.loadAsync(
//            "celllog_cleaned.json",
//            as: CellLogRootDTO.self
//        )
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//
//        var results: [Location] = []
//
//        for dto in root.locations {
//            let timestamp = formatter.date(from: dto.timestamp) ?? Date()
//
//            var lat: Double = 0
//            var lon: Double = 0
//            var resolvedAddress = dto.address
//
//            // Geocode
//            do {
//                let geocode = try await NaverGeocodeAPIService.shared.geocode(address: dto.address)
//
//                if let gLat = geocode.latitude,
//                   let gLon = geocode.longitude
//                {
//                    lat = gLat
//                    lon = gLon
//                    resolvedAddress = geocode.fullAddress
//                } else {
//                    print("[MockLoader] Geocode 결과 없음 → fallback: \(dto.address)")
//                }
//            } catch {
//                print("[MockLoader] Geocode 실패 → fallback (0,0): \(dto.address)")
//            }
//            // ----------------------------------------------------------
//
//            let location = Location(
//                id: UUID(),
//                address: resolvedAddress,
//                title: nil,
//                note: dto.notes,
//                pointLatitude: lat,
//                pointLongitude: lon,
//                boxMinLatitude: nil,
//                boxMinLongitude: nil,
//                boxMaxLatitude: nil,
//                boxMaxLongitude: nil,
//                locationType: 2, // 기지국 데이터 고정
//                colorType: 0,
//                receivedAt: timestamp
//            )
//
//            results.append(location)
//        }
//
//        return results
//    }
// }

private nonisolated struct CellLogDTO: Decodable, Sendable {
    let timestamp: String
    let address: String
    let latitude: Double
    let longitude: Double
    let message: String
    let notes: String?
}

enum LocationMockLoader {
    static func loadCellLogSampleWithGeocode() async throws -> [Location] {
        let dtos: [CellLogDTO] = try await JSONLoader.loadAsync(
            "celllog_cleaned.json",
            as: [CellLogDTO].self
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        var results: [Location] = []
        
        for dto in dtos {
            let timestamp = formatter.date(from: dto.timestamp) ?? Date()
            
            let lat = dto.latitude
            let lon = dto.longitude
            let resolvedAddress = dto.address
            
            let location = Location(
                id: UUID(),
                address: resolvedAddress,
                title: nil,
                note: dto.notes,
                pointLatitude: lat,
                pointLongitude: lon,
                boxMinLatitude: nil,
                boxMinLongitude: nil,
                boxMaxLatitude: nil,
                boxMaxLongitude: nil,
                locationType: 2,
                colorType: 0,
                receivedAt: timestamp
            )
            
            results.append(location)
        }
        
        return results
    }
    
    // MARK: - 핀 데이터 로드
    
    /// 핀 데이터를 로드합니다 (locationType = 0, 1, 3)
    /// - Returns: Location 배열 (핀 타입)
    /// - Throws: JSON 로딩 에러
    static func loadPinDataSample() async throws -> [Location] {
        let dtos: [PinDataDTO] = try await JSONLoader.loadAsync(
            "locations_geocoded.json",
            as: [PinDataDTO].self
        )
        
        var results: [Location] = []
        
        for dto in dtos {
            // UUID 변환 (실패 시 새로 생성)
            let locationId = UUID(uuidString: dto.id) ?? UUID()
            
            print(dto)
            
            let location = Location(
                id: locationId,
                address: dto.address,
                title: dto.title.isEmpty ? nil : dto.title,
                note: dto.note.isEmpty ? nil : dto.note,
                pointLatitude: dto.pointLatitude,
                pointLongitude: dto.pointLongitude,
                boxMinLatitude: nil,
                boxMinLongitude: nil,
                boxMaxLatitude: nil,
                boxMaxLongitude: nil,
                locationType: Int16(dto.locationType),
                colorType: Int16(dto.colorType),
                receivedAt: nil // 핀 데이터는 시간 정보 없음
            )
            
            results.append(location)
        }
        
        print("✅ [LocationMockLoader] 핀 데이터 로드 완료 → \(results.count)개")
        return results
    }
}

private nonisolated struct PinDataDTO: Decodable, Sendable {
    let id: String
    let locationType: Int
    let pointLatitude: Double
    let pointLongitude: Double
    let address: String
    let title: String
    let note: String
    let colorType: Int
    let geocodeSource: String
}
