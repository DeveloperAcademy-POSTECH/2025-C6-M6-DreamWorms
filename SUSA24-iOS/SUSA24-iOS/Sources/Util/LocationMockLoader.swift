//
//  LocationMockLoader.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/3/25.
//

import Foundation
import CoreData

nonisolated private struct WeeklyCellLocationDTO: Decodable, Sendable {
    let address: String
    let receivedAt: Date
    let pointLatitude: Double
    let pointLongitude: Double
    
    enum CodingKeys: String, CodingKey {
        case address
        case receivedAt
        case pointLatitude
        case pointLongitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        pointLatitude = try container.decode(Double.self, forKey: .pointLatitude)
        pointLongitude = try container.decode(Double.self, forKey: .pointLongitude)
        
        let dateString = try container.decode(String.self, forKey: .receivedAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .receivedAt,
                in: container,
                debugDescription: "Invalid date format: \(dateString). Expected format: yyyy-MM-dd'T'HH:mm:ss"
            )
        }
        receivedAt = date
    }
}

enum LocationMockLoader {
    static func loadWeeklyCellSampleAsync() async throws -> [Location] {
        let dtos: [WeeklyCellLocationDTO] = try await JSONLoader.loadAsync("weekly_cell_sample.json", as: [WeeklyCellLocationDTO].self)
        return dtos.map { dto in
            Location(
                id: UUID(),
                address: dto.address,
                title: nil,
                note: nil,
                pointLatitude: dto.pointLatitude,
                pointLongitude: dto.pointLongitude,
                boxMinLatitude: nil,
                boxMinLongitude: nil,
                boxMaxLatitude: nil,
                boxMaxLongitude: nil,
                locationType: Int16.random(in: 0...3),
                colorType: Int16.random(in: 0...6),
                receivedAt: dto.receivedAt
            )
        }
    }
    
    static func loadAndSaveToCoreData(caseId: UUID, context: NSManagedObjectContext) async throws {
        let locations = try await loadWeeklyCellSampleAsync()
        let repository = LocationRepository(context: context)
        try await repository.createLocations(data: locations, caseId: caseId)
    }
}
