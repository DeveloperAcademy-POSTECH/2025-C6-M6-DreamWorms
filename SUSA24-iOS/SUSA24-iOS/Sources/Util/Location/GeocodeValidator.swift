//
//  GeocodeValidator.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/17/25.
//

import Foundation

// MARK: - GeocodeResult

struct GeocodeResult: Sendable {
    let originalAddress: String
    let normalizedAddress: String?
    let latitude: Double?
    let longitude: Double?
    let errorMessage: String?
    
    var isValid: Bool {
        normalizedAddress != nil && latitude != nil && longitude != nil
    }
}

// MARK: - GeocodeValidator

enum GeocodeValidator {
    // MARK: - Single
    
    /// 단일 주소 하나만 검증
    static func validate(address: String) async -> GeocodeResult {
        do {
            let geocodeResult = try await NaverGeocodeAPIService.shared.geocode(address: address)
            
            guard
                let latitude = geocodeResult.latitude,
                let longitude = geocodeResult.longitude
            else {
                // 좌표 없음 → 실패 결과
                let message = GeocodeValidError.noCoordinates.errorDescription
                    ?? "좌표를 찾을 수 없습니다"
                
                return GeocodeResult(
                    originalAddress: address,
                    normalizedAddress: nil,
                    latitude: nil,
                    longitude: nil,
                    errorMessage: message
                )
            }
            
            // 성공 결과
            return GeocodeResult(
                originalAddress: address,
                normalizedAddress: geocodeResult.fullAddress,
                latitude: latitude,
                longitude: longitude,
                errorMessage: nil
            )
            
        } catch {
            let message: String = if let e = error as? LocalizedError, let desc = e.errorDescription {
                desc
            } else {
                String(describing: error)
            }
            
            return GeocodeResult(
                originalAddress: address,
                normalizedAddress: nil,
                latitude: nil,
                longitude: nil,
                errorMessage: message
            )
        }
    }
    
    // MARK: - Parallel
    
    static func validateParallel(
        addresses: [String],
        progressHandler: (@MainActor (_ current: Int, _ total: Int) async -> Void)? = nil
    ) async -> [GeocodeResult] {
        guard !addresses.isEmpty else { return [] }
        
        var results: [GeocodeResult] = []
        var completed = 0
        
        await withTaskGroup(of: (Int, GeocodeResult).self) { group in
            for (idx, address) in addresses.enumerated() {
                group.addTask {
                    let result = await validate(address: address)
                    return (idx, result)
                }
            }
            
            var temp: [(Int, GeocodeResult)] = []
            
            for await (idx, result) in group {
                temp.append((idx, result))
                completed += 1
                
                if let handler = progressHandler {
                    await handler(completed, addresses.count)
                }
            }
            
            results = temp.sorted { $0.0 < $1.0 }.map(\.1)
        }
        
        return results
    }
    
    // MARK: - Sequential
    
    static func validateSequential(
        addresses: [String],
        delay: TimeInterval = 0.1,
        progressHandler: (@MainActor (_ current: Int, _ total: Int) async -> Void)? = nil
    ) async -> [GeocodeResult] {
        guard !addresses.isEmpty else { return [] }
        
        var results: [GeocodeResult] = []
        
        for (idx, address) in addresses.enumerated() {
            let result = await validate(address: address)
            results.append(result)
            
            if let handler = progressHandler {
                await handler(idx + 1, addresses.count)
            }
            
            if idx < addresses.count - 1 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        return results
    }
    
    // MARK: - Statistics

    struct ValidationStatistics {
        let totalCount: Int
        let successCount: Int
        let failureCount: Int
        
        var successRate: Double {
            guard totalCount > 0 else { return 0 }
            return Double(successCount) / Double(totalCount)
        }
        
        var successPercentage: Int {
            Int(successRate * 100)
        }
    }
    
    static func calculateStatistics(from results: [GeocodeResult]) -> ValidationStatistics {
        let success = results.filter(\.isValid).count
        let failure = results.count - success
        
        return ValidationStatistics(
            totalCount: results.count,
            successCount: success,
            failureCount: failure
        )
    }
}

// MARK: - Errors

enum GeocodeValidError: Error, LocalizedError {
    case noCoordinates
    case unknown
    case invalidAddress
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noCoordinates: "좌표를 찾을 수 없습니다"
        case .unknown: "알 수 없는 오류"
        case .invalidAddress: "유효하지 않은 주소"
        case .networkError: "네트워크 오류"
        }
    }
}
