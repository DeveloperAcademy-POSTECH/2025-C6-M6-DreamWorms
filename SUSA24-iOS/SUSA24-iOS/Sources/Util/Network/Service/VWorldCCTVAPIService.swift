//
//  VWorldCCTVAPIService.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/10/25.
//

import Foundation

/// VWorld API 서비스
final class VWorldCCTVAPIService: CCTVAPIService {
    // MARK: - Public Methods
    
    /// BOX로 CCTV 정보를 조회합니다.
    /// - Parameter requestDTO: BOX 조회 요청 DTO
    /// - Returns: CCTV 정보 응답
    /// - Throws: `VWorldError`
    func fetchCCTVByBox(_ requestDTO: VWorldBoxRequestDTO) async throws -> VWorldCCTVResponseDTO {
        let endpoint = VWorldEndpoint.cctvBox(requestDTO)
        
        do {
            let response: VWorldCCTVResponseDTO = try await NetworkClient.shared.request(
                endpoint: endpoint
            )
            
            guard !response.features.isEmpty else { throw VWorldError.noResults }
            return response
            
        } catch let error as VWorldError {
            throw error
        } catch let error as NetworkError {
            throw VWorldError.networkError(error)
        } catch {
            throw VWorldError.unknown(error)
        }
    }
    
    /// Polygon으로 CCTV 정보를 조회합니다.
    /// - Parameter requestDTO: Polygon 조회 요청 DTO
    /// - Returns: CCTV 정보 응답
    /// - Throws: `VWorldError`
    func fetchCCTVByPolygon(_ requestDTO: VWorldPolygonRequestDTO) async throws -> VWorldCCTVResponseDTO {
        let endpoint = VWorldEndpoint.cctvPolygon(requestDTO)
        
        do {
            let response: VWorldCCTVResponseDTO = try await NetworkClient.shared.request(
                endpoint: endpoint
            )
            
            guard !response.features.isEmpty else { throw VWorldError.noResults }
            return response
            
        } catch let error as VWorldError {
            throw error
        } catch let error as NetworkError {
            throw VWorldError.networkError(error)
        } catch {
            throw VWorldError.unknown(error)
        }
    }
}
