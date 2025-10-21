//  VisionService.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/21/25.
//

import CoreVideo
import Foundation
import Vision

actor VisionService {
    func recognizeText(
        from pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation = .up
    ) async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            let request = VNRecognizeTextRequest { req, err in
                if let err {
                    cont.resume(throwing: err)
                    return
                }
                let observations = (req.results as? [VNRecognizedTextObservation]) ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                cont.resume(returning: lines.joined(separator: "\n"))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.01
            request.recognitionLanguages = ["ko-KR"]
            
            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer,
                orientation: orientation,
                options: [:]
            )
            
            do {
                try handler.perform([request])
            } catch {
                cont.resume(throwing: error)
            }
        }
    }
    
    /// 인식된 텍스트에서 주소만 추출
    func extractAddresses(in text: String) -> [String] {
        var results: [String] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
            let nsRange = NSRange(text.startIndex ..< text.endIndex, in: text)
            detector.enumerateMatches(in: text, options: [], range: nsRange) { match, _, _ in
                guard let match, match.resultType == .address,
                      let range = Range(match.range, in: text) else { return }
                results.append(String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        } catch {
            // 실패해도 폴백 규칙으로 보완
        }
        
        let fallback = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { line in
                line.count >= 6 &&
                    (line.contains("시") || line.contains("군") || line.contains("구")) &&
                    (line.contains("로") || line.contains("길") || line.contains("동"))
            }
        
        let merged = (results + fallback).reduce(into: [String]()) { acc, s in
            if !acc.contains(s) { acc.append(s) }
        }
        return merged
    }
    
    /// 한 번에 "주소 인식"까지
    func recognizeAddresses(from pixelBuffer: CVPixelBuffer) async throws -> (fullText: String, addresses: [String]) {
        let text = try await recognizeText(from: pixelBuffer, orientation: .up)
        let addrs = extractAddresses(in: text)
        return (text, addrs)
    }
}
