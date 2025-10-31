//
//  GeocodeService.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import Alamofire
import Foundation

final class GeocodeService {
    static let shared = GeocodeService()
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

        let response = try JSONDecoder().decode(GeocodeResponseDTO.self, from: requestData)

        guard response.status == "OK" else {
            throw GeocodeError.invalidStatus(response.status, response.errorMessage)
        }
        guard let address = response.addresses.first else {
            throw GeocodeError.noResults
        }
        return address
    }
}
