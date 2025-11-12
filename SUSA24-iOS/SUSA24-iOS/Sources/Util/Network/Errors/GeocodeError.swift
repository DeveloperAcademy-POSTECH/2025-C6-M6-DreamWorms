//
//  GeocodeError.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/11/25.
//

import Foundation

enum GeocodeError: LocalizedError, Sendable {
    case invalidStatus(String, String)
    case noResults
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case let .invalidStatus(status, message):
            "Geocoding failed: \(status) - \(message)"
        case .noResults:
            "No results found"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        }
    }
}
