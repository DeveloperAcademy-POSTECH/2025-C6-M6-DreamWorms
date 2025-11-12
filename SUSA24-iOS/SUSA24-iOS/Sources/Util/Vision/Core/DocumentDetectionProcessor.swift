//
//  DocumentDetectionProcessor.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import CoreImage
import CoreVideo
import Foundation
import Vision

/// 프레임을 처리하고 문서 감지 + 렌즈 얼룩 감지 결과를 스트림으로 제공합니다 (매 프레임)
actor DocumentDetectionProcessor {
    // 문서 감지
    private var documentContinuation: AsyncStream<DocumentDetectionResult>.Continuation?
    private let documentStream: AsyncStream<DocumentDetectionResult>
    
    // 렌즈 얼룩 감지
    private var smudgeContinuation: AsyncStream<LensSmudgeDetectionResult>.Continuation?
    private let smudgeStream: AsyncStream<LensSmudgeDetectionResult>
    
    // 성능 추적
    private var frameCount: Int = 0
    private var processedFrameCount: Int = 0
    private var totalProcessingTime: TimeInterval = 0
    
    private let sessionQueue = DispatchSerialQueue(label: "com.dreamworms.susa24.vision.processingQueue")
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }
    
    init() {
        // 문서 감지 스트림 설정 (최신 버퍼 정책)
        var docCont: AsyncStream<DocumentDetectionResult>.Continuation?
        self.documentStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            docCont = continuation
        }
        self.documentContinuation = docCont
        
        // 렌즈 얼룩 스트림 설정 (최신 버퍼 정책)
        var smudgeCont: AsyncStream<LensSmudgeDetectionResult>.Continuation?
        self.smudgeStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            smudgeCont = continuation
        }
        self.smudgeContinuation = smudgeCont
    }
    
    /// 프레임을 처리합니다 (매 프레임 처리)
    /// - Parameters:
    ///   - buffer: CVImageBuffer
    ///   - timestamp: 프레임 타임스탐프
    func processFrame(
        _ buffer: CVImageBuffer,
        timestamp: TimeInterval
    ) async {
        frameCount += 1
        
        // (3fps)
        guard frameCount % 10 == 0 else {
            return
        }
        
        processedFrameCount += 1
        let startTime = Date().timeIntervalSinceReferenceDate
        
        // 병렬 처리: 문서 감지 + 렌즈 얼룩 감지
        let docResult = detectDocument(buffer, timestamp: timestamp)
        let smudgeResult = await detectLensSmudge(buffer, timestamp: timestamp)
        
        // 결과 스트림에 전송
        // 문서가 감지되면 전송 (nil일 경우는 전송 안 함)
        if let doc = docResult {
            documentContinuation?.yield(doc)
        }
        
        // 렌즈 얼룩은 항상 감지 상태를 전송
        smudgeContinuation?.yield(smudgeResult)
        
        // 성능 메트릭 업데이트
        let processingTime = Date().timeIntervalSinceReferenceDate - startTime
        updatePerformanceMetrics(processingTime: processingTime)
    }
    
    /// 결과 스트림들을 반환합니다 (nonisolated)
    nonisolated func getResultStream() -> AsyncStream<DocumentDetectionResult> {
        documentStream
    }
    
    nonisolated func getSmudgeStream() -> AsyncStream<LensSmudgeDetectionResult> {
        smudgeStream
    }
    
    /// 문서를 감지합니다 (VNDetectDocumentSegmentationRequest)
    private func detectDocument(
        _ buffer: CVImageBuffer,
        timestamp: TimeInterval
    ) -> DocumentDetectionResult? {
        let ciImage = CIImage(cvImageBuffer: buffer)
        
        let request = VNDetectDocumentSegmentationRequest()
        let requestHandler = VNImageRequestHandler(
            ciImage: ciImage,
            orientation: .up
        )
        
        do {
            try requestHandler.perform([request])
            
            // VNDetectDocumentSegmentationRequest는 VNRectangleObservation을 반환
            guard let results = request.results,
                  let observation = results.first
            else {
                return nil
            }
            
            // 신뢰도가 0.5 이상만 유효
            guard observation.confidence >= 0.5 else {
                return nil
            }
            
            // 4개 꼭짓점 추출
            let corners = [
                observation.topLeft,
                observation.topRight,
                observation.bottomRight,
                observation.bottomLeft,
            ]
            
            return DocumentDetectionResult(
                boundingBox: observation.boundingBox,
                corners: corners,
                confidence: observation.confidence,
                timestamp: timestamp
            )
        } catch {
            print("❌ 문서 감지 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 렌즈 얼룩을 감지합니다 (iOS 26+, async/await API)
    /// - Note: DetectLensSmudgeRequest는 async/await 패턴 사용
    private func detectLensSmudge(
        _ buffer: CVImageBuffer,
        timestamp: TimeInterval
    ) async -> LensSmudgeDetectionResult {
        let ciImage = CIImage(cvImageBuffer: buffer)
        
        do {
            // iOS 26+: DetectLensSmudgeRequest 사용 (async/await)
            let request = DetectLensSmudgeRequest(.revision1)
            let smudgeObservation = try await request.perform(on: ciImage, orientation: .up)
            
            return LensSmudgeDetectionResult(
                confidence: smudgeObservation.confidence,
                isSmudged: smudgeObservation.confidence > 0.5,
                timestamp: timestamp
            )
        } catch {
            // 감지 실패 시 깨끗하다고 가정
            return LensSmudgeDetectionResult(
                confidence: 0.0,
                isSmudged: false,
                timestamp: timestamp
            )
        }
    }
    
    /// 성능 메트릭을 업데이트하고 출력합니다
    private func updatePerformanceMetrics(processingTime: TimeInterval) {
        totalProcessingTime += processingTime
        
        // 50번 처리마다 성능 정보 출력
        if processedFrameCount % 50 == 0 {
            let averageTime = totalProcessingTime / TimeInterval(processedFrameCount)
            let fps = 1.0 / averageTime
        }
    }
    
    /// 스트림을 정리합니다
    func cleanup() {
        documentContinuation?.finish()
        smudgeContinuation?.finish()
        documentContinuation = nil
        smudgeContinuation = nil
    }
}
