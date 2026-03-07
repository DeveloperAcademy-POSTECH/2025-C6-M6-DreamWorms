//
//  CapturedPhoto+.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/8/25.
//

import UIKit
import Vision

// MARK: - CameraScene 에서만 사용하는 CapturedPhoto Extensions

extension CapturedPhoto {
    /// 사진 데이터를 UIImage로 변환
    var uiImage: UIImage? {
        UIImage(data: data)
    }
}

// MARK: - Hashable

extension CapturedPhoto: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Equatable

extension CapturedPhoto: Equatable {
    static func == (lhs: CapturedPhoto, rhs: CapturedPhoto) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 흔들림 여부

extension CapturedPhoto {
    /// 사진에서 문서/텍스트를 인식할 수 없는지 여부
    /// - Returns: 인식 불가능하면 true, 인식 가능하면 false
    /// - Note: Vision Framework의 VNRecognizeTextRequest를 사용하여 실제 텍스트 인식 가능 여부 체크
    var isUnreadable: Bool {
        guard let cgImage = uiImage?.cgImage else {
            return true // 이미지 변환 실패 = 인식 불가
        }
        
        let result = recognizeText(from: cgImage)
        
        let isUnreadable = !result.isReadable
        if isUnreadable {
            // 문석 인식 실패
        } else {
            // 문서 인식
        }
        
        return isUnreadable
    }
    
    /// 텍스트 인식을 수행
    /// - Parameter cgImage: 분석할 CGImage
    /// - Returns: 텍스트 인식 결과
    private func recognizeText(from cgImage: CGImage) -> TextRecognitionResult {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast // 빠른 인식
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results, !observations.isEmpty else {
                return TextRecognitionResult(
                    recognizedCount: 0,
                    averageConfidence: 0.0,
                    isReadable: false
                )
            }
            
            // 신뢰도가 0.3 이상인 텍스트만 카운트
            let validObservations = observations.filter { $0.confidence > 0.3 }
            
            let recognizedCount = validObservations.count
            let totalConfidence = validObservations.reduce(0.0) { $0 + $1.confidence }
            let averageConfidence = recognizedCount > 0 ? totalConfidence / Float(recognizedCount) : 0.0
            
            // 읽기 가능 여부 판단:
            // 1. 최소 2개 이상의 텍스트 인식
            // 2. 평균 신뢰도 0.5 이상
            let isReadable = recognizedCount >= 2 && averageConfidence >= 0.5
            
            return TextRecognitionResult(
                recognizedCount: recognizedCount,
                averageConfidence: averageConfidence,
                isReadable: isReadable
            )
            
        } catch {
            return TextRecognitionResult(
                recognizedCount: 0,
                averageConfidence: 0.0,
                isReadable: false
            )
        }
    }
}

// MARK: - Supporting Types

/// 텍스트 인식 결과
private struct TextRecognitionResult {
    /// 인식된 텍스트 개수
    let recognizedCount: Int
    
    /// 평균 신뢰도 (0.0 ~ 1.0)
    let averageConfidence: Float
    
    /// 읽기 가능 여부
    let isReadable: Bool
}

// MARK: - Alternative: 더 엄격한 기준

extension CapturedPhoto {
    /// 더 엄격한 기준으로 문서 인식 가능 여부 체크
    /// - Returns: 인식 불가능하면 true
    /// - Note: 실제 주소/문서 형식인지까지 체크
    var isUnreadableStrict: Bool {
        guard let cgImage = uiImage?.cgImage else {
            return true
        }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate // 정확한 인식
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results, !observations.isEmpty else {
                return true
            }
            
            // 신뢰도 0.5 이상인 텍스트만 카운트
            let validObservations = observations.filter { $0.confidence > 0.5 }
            
            let recognizedCount = validObservations.count
            let totalConfidence = validObservations.reduce(0.0) { $0 + $1.confidence }
            let averageConfidence = recognizedCount > 0 ? totalConfidence / Float(recognizedCount) : 0.0
            
            // 더 엄격한 기준:
            // 1. 최소 10개 이상의 텍스트
            // 2. 평균 신뢰도 0.6 이상
            let isReadable = recognizedCount >= 10 && averageConfidence >= 0.6
            
            print("[TextRecognition-Strict] 인식된 텍스트: \(recognizedCount)개, 평균 신뢰도: \(String(format: "%.2f", averageConfidence)), 읽기 가능: \(isReadable)")
            
            return !isReadable
            
        } catch {
            print("[TextRecognition-Strict] 텍스트 인식 실패: \(error.localizedDescription)")
            return true
        }
    }
}

// MARK: - Backward Compatibility

extension CapturedPhoto {
    /// 이전 흔들림 감지 속성과의 호환성 유지
    /// - Note: 이제 isUnreadable을 사용하지만, 기존 코드 호환을 위해 유지
    var isBlurred: Bool {
        // 텍스트 인식 기반으로 변경
        isUnreadable
    }
}
