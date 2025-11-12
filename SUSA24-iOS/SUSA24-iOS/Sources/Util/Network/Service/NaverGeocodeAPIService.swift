//
//  NaverGeocodeAPIService.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/11/25.
//

import Alamofire
import Foundation

// TODO: `NetworkClient`를 사용하도록 리팩토링 필요.
final class NaverGeocodeAPIService {
    static let shared = NaverGeocodeAPIService()
    private init() {}
    
    private let session: Session = {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 10
        return Session(configuration: config)
    }()

    func geocode(address: String) async throws -> Address {
        let url = URLConstant.geocodeURL
        let parameters: [String: String] = ["query": address]
        let headers: HTTPHeaders = [
            NetworkConstant.NaverAPIHeaderKey.clientID: Config.naverMapClientID,
            NetworkConstant.NaverAPIHeaderKey.clientSecret: Config.naverMapClientSecret,
        ]

        let requestData = try await session
            .request(url, method: .get, parameters: parameters, headers: headers)
            .serializingData()
            .value

        let response = try JSONDecoder().decode(NaverGeocodeResponseDTO.self, from: requestData)

        guard response.status == "OK" else {
            throw GeocodeError.invalidStatus(response.status, response.errorMessage)
        }
        guard let address = response.addresses.first else {
            throw GeocodeError.noResults
        }
        return address
    }
}
