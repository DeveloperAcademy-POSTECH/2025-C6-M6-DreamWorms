//
//  CameraModel+Vision.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import AVFoundation
import SwiftUI
import Vision

extension CameraModel {
    /// Vision 분석을 활성화합니다
    /// - Note: 이미 활성화되어 있으면 무시
    func enableVisionAnalysis() {
        guard visionProcessor == nil else {
            return
        }
        
        visionProcessor = DocumentDetectionProcessor()
        isVisionEnabled = true
    }
    
    /// Vision 분석을 시작합니다 (프레임 스트림에서 읽음)
    /// - Note: enableVisionAnalysis() 호출 후에 사용하세요
    func startVisionAnalysis() async {
        guard let processor = visionProcessor else {
            return
        }
        
        guard let frameStream = getFrameStream() else {
            return
        }
        
        var frameIndex: UInt64 = 0
        let startTime = TimeInterval(Date().timeIntervalSinceReferenceDate)
        
        // 프레임 스트림에서 이미지를 읽고 Vision 분석 실행
        for await buffer in frameStream {
            let timestamp = TimeInterval(Date().timeIntervalSinceReferenceDate) - startTime
            frameIndex += 1
            
            // Vision 분석 (actor context에서 진행)
            await processor.processFrame(buffer, timestamp: timestamp)
        }
    }
    
    /// 문서 감지 결과 스트림을 반환합니다
    /// - Returns: 비동기 스트림 (문서 감지 결과), 프로세서가 없으면 nil
    /// - Important: enableVisionAnalysis()가 먼저 호출되어야 합니다
    func getDocumentDetectionStream() -> AsyncStream<DocumentDetectionResult>? {
        guard let processor = visionProcessor else {
            return nil
        }
        
        // nonisolated 메서드를 통해 MainActor에서 안전하게 접근
        return processor.getResultStream()
    }
    
    /// 렌즈 얼룩 감지 결과 스트림을 반환합니다
    /// - Returns: 비동기 스트림 (렌즈 얼룩 감지 결과), 프로세서가 없으면 nil
    /// - Important: enableVisionAnalysis()가 먼저 호출되어야 합니다
    func getLensSmudgeStream() -> AsyncStream<LensSmudgeDetectionResult>? {
        guard let processor = visionProcessor else {
            return nil
        }
        
        return processor.getSmudgeStream()
    }
    
    /// Vision 분석을 중지하고 리소스를 정리합니다
    func stopVisionAnalysis() {
        guard let processor = visionProcessor else {
            return
        }
        
        // Actor 메서드를 비동기로 호출
        Task {
            await processor.cleanup()
        }
        
        visionProcessor = nil
        isVisionEnabled = false
    }
}

// MARK: - Observable Computed Properties (SwiftUI용)

extension CameraModel {
    /// 문서가 감지되었는지 여부 (UI용 computed property)
    var isDocumentDetected: Bool {
        false // View에서 documentDetection != nil로 확인하세요
    }
    
    /// 마지막 감지된 문서의 신뢰도 (0.0 ~ 1.0)
    var documentDetectionConfidence: Float {
        0.0 // 기본값
    }
}
