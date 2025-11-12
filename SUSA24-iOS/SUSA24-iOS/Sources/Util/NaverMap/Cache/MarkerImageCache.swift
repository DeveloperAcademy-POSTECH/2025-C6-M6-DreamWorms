//
//  MarkerImageCache.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/12/25.
//

import SwiftUI

/// SwiftUI Marker를 UIImage로 변환하고 캐싱하는 싱글톤 액터
/// - 네이버 지도 마커에 사용할 이미지를 효율적으로 관리합니다.
actor MarkerImageCache {
    // MARK: - Singleton
    
    static let shared = MarkerImageCache()
    
    private init() {}
    
    // MARK: - Cache Storage
    
    private var cache: [String: UIImage] = [:]
    
    // MARK: - Public Methods
    
    /// MarkerType에 해당하는 UIImage를 반환합니다.
    /// - 캐시에 있으면 즉시 반환, 없으면 생성 후 캐싱
    /// - Parameter type: 마커 타입
    /// - Returns: 변환된 UIImage
    func image(for type: MarkerType) async -> UIImage {
        let key = type.cacheKey
        if let cachedImage = cache[key] { return cachedImage }
        
        // 캐시에 없으면 생성
        let newImage = await generateImage(for: type)
        cache[key] = newImage
        return newImage
    }
    
    /// 특정 MarkerType의 캐시를 제거합니다.
    /// - Parameter type: 제거할 마커 타입
    func removeCache(for type: MarkerType) { cache[type.cacheKey] = nil }
    
    /// 모든 캐시를 제거합니다.
    func clearAll() { cache.removeAll() }
    
    // MARK: - Private Methods
    
    /// SwiftUI Marker를 UIImage로 변환합니다.
    /// - Parameter type: 마커 타입
    /// - Returns: 변환된 UIImage
    private func generateImage(for type: MarkerType) async -> UIImage {
        await MainActor.run {
            let marker = Marker(type: type)
            let renderer = ImageRenderer(content: marker)
            renderer.scale = UIScreen.main.scale
            guard let uiImage = renderer.uiImage else {
                return createPlaceholderImage(size: CGSize(width: 40, height: 40))
            }
            return uiImage
        }
    }
    
    /// 변환 실패 시 사용할 기본 이미지를 생성합니다.
    /// - Parameter size: 이미지 크기
    /// - Returns: 기본 UIImage
    private nonisolated func createPlaceholderImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.gray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Preload Support

extension MarkerImageCache {
    /// 자주 사용되는 마커 타입을 미리 로드합니다.
    func preloadCommonMarkers() async {
        let commonTypes: [MarkerType] = [
            .home,
            .work,
            .cell(isVisited: false),
            .cell(isVisited: true),
            .cctv,
            .custom,
        ]
        
        await withTaskGroup(of: Void.self) { group in
            for type in commonTypes {
                group.addTask {
                    _ = await self.image(for: type)
                }
            }
        }
    }
}
