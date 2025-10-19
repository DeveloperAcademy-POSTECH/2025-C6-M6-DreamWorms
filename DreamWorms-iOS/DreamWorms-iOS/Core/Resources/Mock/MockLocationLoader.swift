//
//  MockLocationLoader.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/19/25.
//

import Foundation
import CoreLocation

struct MockLocation: Codable, Identifiable {
    
    var id: String { "\(location),\(receivedAt)" }
    
    let location: String
    let latitude: Double
    let longitude: Double
    let receivedAt: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var timestamp: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: receivedAt) ?? Date()
    }
}

enum MockLocationLoader {
    static func loadFromJSON() -> [MockLocation] {
        guard let url = Bundle.main.url(forResource: "mock_location", withExtension: "json") else {
            print("mock_location.json not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let locations = try decoder.decode([MockLocation].self, from: data)
            print("Loaded \(locations.count) mock locations")
            return locations
        } catch {
            print("Failed to decode mock_location.json: \(error)")
            return []
        }
    }
}
