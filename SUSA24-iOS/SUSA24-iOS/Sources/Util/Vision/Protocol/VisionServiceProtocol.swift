//
//  VisionServiceProtocol.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import Foundation
import CoreVideo

/// Vision Framework 기능을 제공하는 서비스 프로토콜
///
/// ## 주요 기능
/// - 실시간 문서 감지 (카메라 스트림)
/// - 렌즈 얼룩 감지
/// - 이미지에서 주소 추출 (단일/배치)
///
/// ## 사용 예시
/// ```swift
/// let visionService: VisionServiceProtocol = VisionService()
///
/// // 실시간 문서 감지
/// let documentStream = await visionService.startDocumentDetection(
///     frameStream: cameraFrameStream
/// )
///
/// for await detection in documentStream {
///     print("문서 감지: \(detection.confidence)")
/// }
///
/// // 주소 추출
/// let result = try await visionService.extractAddresses(from: imageData)
/// print("추출된 주소: \(result.addresses)")
/// ```
protocol VisionServiceProtocol: Sendable {
    
    // MARK: - 실시간 감지
    
    /// 프레임 스트림에서 문서를 실시간으로 감지합니다.
    ///
    /// - Parameter frameStream: 카메라 프레임 스트림
    /// - Returns: 문서 감지 결과 스트림
    ///
    /// ## Note
    /// - 약 6fps로 샘플링하여 감지합니다
    /// - 신뢰도 0.5 이상만 반환됩니다
    /// - Task가 취소되면 스트림도 자동 종료됩니다
    func startDocumentDetection(
        frameStream: AsyncStream<CVImageBuffer>
    ) async -> AsyncStream<DocumentDetectionResult>
    
    /// 프레임 스트림에서 렌즈 얼룩을 실시간으로 감지합니다.
    ///
    /// - Parameter frameStream: 카메라 프레임 스트림
    /// - Returns: 렌즈 얼룩 감지 결과 스트림
    ///
    /// ## Note
    /// - iOS 26+ 필수 (DetectLensSmudgeRequest)
    /// - 신뢰도 0.5 이상이면 얼룩으로 판단합니다
    func startLensSmudgeDetection(
        frameStream: AsyncStream<CVImageBuffer>
    ) async -> AsyncStream<LensSmudgeDetectionResult>
    
    // MARK: - 주소 추출
    
    /// 단일 이미지에서 한국 주소를 추출합니다.
    ///
    /// - Parameter imageData: 분석할 이미지 데이터 (JPEG/PNG)
    /// - Returns: 주소 추출 결과 (테이블/텍스트 포함)
    /// - Throws: `VisionAnalysisError` 분석 실패 시
    ///
    /// ## 추출 로직
    /// 1. RecognizeDocumentsRequest로 문서 분석
    /// 2. 테이블이 있으면 테이블에서만 추출
    /// 3. 테이블이 없으면 텍스트에서 추출
    /// 4. 한국 주소 패턴 매칭 및 정규화
    ///
    /// ## 예시
    /// ```swift
    /// let result = try await visionService.extractAddresses(from: imageData)
    /// print("총 \(result.totalCount)개 주소 발견")
    /// print("고유 주소: \(result.uniqueCount)개")
    /// ```
    func extractAddresses(
        from imageData: Data
    ) async throws -> AddressExtractionResult
    
    /// 여러 이미지에서 주소를 배치로 추출하고 중복을 카운팅합니다.
    ///
    /// - Parameter photos: 분석할 이미지 데이터 배열
    /// - Returns: [주소: 중복 횟수] 딕셔너리
    /// - Throws: `VisionAnalysisError` 분석 실패 시
    ///
    /// ## 병렬 처리
    /// - TaskGroup을 사용하여 병렬 분석
    /// - 각 이미지는 독립적으로 처리
    /// - 실패한 이미지는 무시하고 계속 진행
    ///
    /// ## 예시
    /// ```swift
    /// let addresses = try await visionService.extractAddressesBatch(from: photosData)
    /// for (address, count) in addresses.sorted(by: { $0.value > $1.value }) {
    ///     print("\(address): \(count)회")
    /// }
    /// ```
    func extractAddressesBatch(
        from photos: [Data]
    ) async throws -> [String: Int]
    
    // MARK: - Progress Tracking (Optional)
    
    /// 배치 처리 진행률을 추적합니다.
    ///
    /// - Parameters:
    ///   - photos: 분석할 이미지 데이터 배열
    ///   - progressHandler: (현재, 전체) 진행률 콜백
    /// - Returns: [주소: 중복 횟수] 딕셔너리
    /// - Throws: `VisionAnalysisError` 분석 실패 시
    func extractAddressesBatchWithProgress(
        from photos: [Data],
        progressHandler: @Sendable @escaping (Int, Int) async -> Void
    ) async throws -> [String: Int]
}

// MARK: - Default Implementations

extension VisionServiceProtocol {
    /// 진행률 추적 없이 배치 추출 (기본 구현)
    func extractAddressesBatch(
        from photos: [Data]
    ) async throws -> [String: Int] {
        try await extractAddressesBatchWithProgress(from: photos) { _, _ in }
    }
}
