//
//  RangeOverlayImageCache.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/13/25.
//

import UIKit

/// 기지국 범위(커버리지) 오버레이 이미지를 생성하고 캐싱하는 액터
actor RangeOverlayImageCache {
    static let shared = RangeOverlayImageCache()
    
    private init() {}
    
    private var cache: [String: UIImage] = [:]
    
    /// 주어진 반경 타입에 대응하는 원형 그라데이션 이미지를 반환합니다.
    /// - Parameter range: 커버리지 반경 타입
    func image(for range: CoverageRangeType) async -> UIImage {
        let key = await CoverageRangeMetadata.cacheKey(for: range)
        if let cached = cache[key] { return cached }
        
        let image = await generateImage()
        cache[key] = image
        return image
    }
    
    func clear() {
        cache.removeAll()
    }
}

// MARK: - Private Helpers

private extension RangeOverlayImageCache {
    /// 단일 표준 이미지(정사각형)를 생성합니다.
    /// 반경 타입에 관계없이 동일 이미지를 사용하고, 지도 좌표 bounds로 스케일링됩니다.
    func generateImage(
        size: CGFloat = 192
    ) async -> UIImage {
        await MainActor.run {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = false
            
            let renderer = UIGraphicsImageRenderer(
                size: CGSize(width: size, height: size),
                format: format
            )
            return renderer.image { context in
                let cgContext = context.cgContext
                let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
                cgContext.addEllipse(in: rect)
                cgContext.clip()
                
                cgContext.setFillColor(UIColor(red: 55 / 255, green: 110 / 255, blue: 228 / 255, alpha: 0.2).cgColor)
                cgContext.fill(rect)
            }
        }
    }
}
