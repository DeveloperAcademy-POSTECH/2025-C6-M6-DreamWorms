//
//  MapBounds+.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

import NMapsMap

extension MapBounds {
    init?(naverBounds: NMGLatLngBounds) {
        let southWest = naverBounds.southWest
        let northEast = naverBounds.northEast
        
        guard southWest.lat <= northEast.lat, southWest.lng <= northEast.lng else { return nil }
        
        self.init(
            minLongitude: southWest.lng,
            minLatitude: southWest.lat,
            maxLongitude: northEast.lng,
            maxLatitude: northEast.lat
        )
    }
}
