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

    /// 사용자 위치용 마커 이미지 반환 (home / work / custom, 색 커스텀)
    /// - Parameters:
    ///   - type: MarkerType.home / .work / .custom
    ///   - color: 핀 색상
    func userLocationImage(for type: MarkerType, color: PinColorType) async -> UIImage {
        let key = "\(type.cacheKey)_\(color.rawValue)"
        if let cachedImage = cache[key] { return cachedImage }

        let newImage = await generateUserLocationImage(for: type, color: color)
        cache[key] = newImage
        return newImage
    }
    
    /// 선택된 위치용 큰 핀 이미지 반환
    /// - 캐시에 있으면 즉시 반환, 없으면 생성 후 캐싱
    /// - Parameter style: 큰 핀 스타일 (home/work/custom/cell + 색 정보)
    func selectedPinImage(for style: SelectedPinStyle) async -> UIImage {
        let key = await style.cacheKey
        if let cachedImage = cache[key] { return cachedImage }
        
        let newImage = await generateSelectedPinImage(for: style)
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
            let marker = MarkerImage(type: type)
            let renderer = ImageRenderer(content: marker)
            renderer.scale = UIScreen.main.scale
            guard let uiImage = renderer.uiImage else {
                return createPlaceholderImage(size: CGSize(width: 40, height: 40))
            }
            return uiImage
        }
    }

    /// 사용자 위치용 마커 이미지를 생성합니다.
    /// - Parameters:
    ///   - type: MarkerType.home / .work / .custom
    ///   - color: 핀 색상
    private func generateUserLocationImage(for type: MarkerType, color: PinColorType) async -> UIImage {
        await MainActor.run {
            let marker: MarkerImage = switch type {
            case .home:
                MarkerImage.home(color: color)
            case .work:
                MarkerImage.work(color: color)
            case .custom:
                MarkerImage.custom(color: color)
            case .cell, .cellWithCount, .cctv:
                // 예상치 못한 타입이 들어오면 기본 구현으로 폴백
                MarkerImage(type: type)
            }

            let renderer = ImageRenderer(content: marker)
            renderer.scale = UIScreen.main.scale
            guard let uiImage = renderer.uiImage else {
                return createPlaceholderImage(size: CGSize(width: 40, height: 40))
            }
            return uiImage
        }
    }
    
    /// 선택된 위치용 큰 핀 이미지를 생성합니다.
    /// - Parameter style: 큰 핀 스타일
    private func generateSelectedPinImage(for style: SelectedPinStyle) async -> UIImage {
        await MainActor.run {
            let marker = SelectedPinImage(style: style)
            let renderer = ImageRenderer(content: marker)
            renderer.scale = UIScreen.main.scale
            guard let uiImage = renderer.uiImage else {
                return createPlaceholderImage(size: CGSize(width: 32, height: 42))
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
