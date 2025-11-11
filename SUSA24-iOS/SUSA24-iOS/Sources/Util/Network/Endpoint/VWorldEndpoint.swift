//
//  VWorldEndpoint.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Alamofire

/// VWorld API Endpoint
enum VWorldEndpoint: Endpoint {
    case cctvBox(VWorldBoxRequestDTO)
    case cctvPolygon(VWorldPolygonRequestDTO)
    
    var url: String {
        switch self {
        case let .cctvBox(dto):
            do {
                let geomFilter = "BOX(\(dto.minLng),\(dto.minLat),\(dto.maxLng),\(dto.maxLat))"
                return try URLBuilder.build(
                    baseURL: URLConstant.vworldCCTVURL,
                    parameters: [
                        "request": "GetFeature",
                        "data": "LT_P_UTISCCTV",
                        "key": Config.VWorldAPIKey,
                        "geomFilter": geomFilter,
                        "format": "json",
                        "size": dto.size,
                        "page": dto.page,
                    ]
                )
            } catch {
                assertionFailure("Failed to build VWorld CCTV Box URL: \(error)")
                return URLConstant.vworldCCTVURL
            }
            
        case let .cctvPolygon(dto):
            do {
                let coordString = dto.coordinates
                    .map { "\($0.longitude) \($0.latitude)" }
                    .joined(separator: ",")
                let geomFilter = "POLYGON((\(coordString)))"
                return try URLBuilder.build(
                    baseURL: URLConstant.vworldCCTVURL,
                    parameters: [
                        "request": "GetFeature",
                        "data": "LT_P_UTISCCTV",
                        "key": Config.VWorldAPIKey,
                        "geomFilter": geomFilter,
                        "format": "json",
                        "size": dto.size,
                        "page": dto.page,
                    ]
                )
            } catch {
                assertionFailure("Failed to build VWorld CCTV Polygon URL: \(error)")
                return URLConstant.vworldCCTVURL
            }
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders? {
        nil
    }
}
