//
//  VisionServiceProtocol.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import CoreVideo
import Foundation

protocol VisionServiceProtocol: Sendable {
    func startDocumentDetection(frameStream: AsyncStream<CVImageBuffer>) async -> AsyncStream<DocumentDetectionResult>
    func startLensSmudgeDetection(frameStream: AsyncStream<CVImageBuffer>) async -> AsyncStream<LensSmudgeDetectionResult>

    func extractAddresses(from imageData: Data) async throws -> AddressExtractionResult

    func extractAddressesBatch(from photos: [Data]) async throws -> [String: Int]

    func extractAddressesBatchWithProgress(
        from photos: [Data],
        progressHandler: @Sendable @escaping (Int, Int) async -> Void
    ) async throws -> [String: Int]

    func cleanup() async
}
