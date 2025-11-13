//
//  CCTVMarker.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

struct CCTVMarker: Equatable, Sendable {
    let id: String
    let name: String
    let location: String
    let latitude: Double
    let longitude: Double
}

extension CCTVMarker {
    init?(feature: VWorldFeature) {
        guard feature.geometry.coordinates.count >= 2 else { return nil }
        let longitude = feature.geometry.coordinates[0]
        let latitude = feature.geometry.coordinates[1]
        self.init(
            id: feature.id,
            name: feature.properties.cctvname,
            location: feature.properties.locate,
            latitude: latitude,
            longitude: longitude
        )
    }
}
