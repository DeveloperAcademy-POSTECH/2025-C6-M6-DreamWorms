//
//  APIClient.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

protocol APIClient: Sendable {
    func request<T: Decodable>(
        endpoint: Endpoint,
        decoder: JSONDecoder
    ) async throws -> T
}
