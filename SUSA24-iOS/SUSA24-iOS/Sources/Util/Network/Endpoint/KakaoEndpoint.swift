//
//  KakaoEndpoint.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Alamofire

/// 카카오 API Endpoint
enum KakaoEndpoint: Endpoint {
    case coordToLocation(KakaoCoordToLocationRequestDTO)
    case keywordToPlace(KakaoKeywordToPlaceRequestDTO)
    
    var url: String {
        switch self {
        case let .coordToLocation(dto):
            do {
                return try URLBuilder.build(
                    baseURL: URLConstant.kakaoCoordToLocationURL,
                    parameters: [
                        "x": dto.x,
                        "y": dto.y,
                        "inputCoord": dto.inputCoord,
                    ]
                )
            } catch {
                assertionFailure("Failed to build Kakao coordToLocation URL: \(error)")
                return URLConstant.kakaoCoordToLocationURL
            }
            
        case let .keywordToPlace(dto):
            do {
                return try URLBuilder.build(
                    baseURL: URLConstant.kakaoKeywordToPlaceURL,
                    parameters: [
                        "query": dto.query,
                        "x": dto.x,
                        "y": dto.y,
                        "radius": dto.radius,
                        "page": dto.page,
                        "size": dto.size,
                    ]
                )
            } catch {
                assertionFailure("Failed to build Kakao keywordToPlace URL: \(error)")
                return URLConstant.kakaoKeywordToPlaceURL
            }
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders? {
        NetworkHeader.kakaoHeaders
    }
}
