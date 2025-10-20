//
//  GradientCircleImageGenerator.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/20/25.
//

import UIKit
import CoreGraphics

final class GradientCircleImageGenerator {
    
    struct GradientStyle {
        let centerColor: UIColor
        let edgeColor: UIColor
        let centerAlpha: CGFloat
        let edgeAlpha: CGFloat
        
        static let defaultStyle = GradientStyle(
            centerColor: .mainBlue,
            edgeColor: .mainBlue,
            centerAlpha: 0.2,
            edgeAlpha: 0.0
        )
    }
    
    private static var imageCache: [String: UIImage] = [:]
    
    static func generateRadialGradientImage(
        size: CGSize,
        style: GradientStyle = .defaultStyle
    ) -> UIImage? {
        let cacheKey = generateCacheKey(size: size, style: style)
        
        if let cachedImage = imageCache[cacheKey] {
            return cachedImage
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            drawRadialGradient(
                in: cgContext,
                center: center,
                radius: radius,
                style: style
            )
        }
        
        imageCache[cacheKey] = image
        return image
    }
    
    private static func drawRadialGradient(
        in context: CGContext,
        center: CGPoint,
        radius: CGFloat,
        style: GradientStyle
    ) {
        guard let gradient = createGradient(from: style) else { return }
        
        let startPoint = center
        let endPoint = center
        
        context.drawRadialGradient(
            gradient,
            startCenter: startPoint,
            startRadius: 0,
            endCenter: endPoint,
            endRadius: radius,
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )
    }
    
    private static func createGradient(from style: GradientStyle) -> CGGradient? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let centerColorWithAlpha = style.centerColor.withAlphaComponent(style.centerAlpha)
        let edgeColorWithAlpha = style.edgeColor.withAlphaComponent(style.edgeAlpha)
        
        guard let centerCGColor = centerColorWithAlpha.cgColor as CGColor?,
              let edgeCGColor = edgeColorWithAlpha.cgColor as CGColor? else {
            return nil
        }
        
        let colors = [centerCGColor, edgeCGColor] as CFArray
        let locations: [CGFloat] = [0.0, 1.0]
        
        return CGGradient(
            colorsSpace: colorSpace,
            colors: colors,
            locations: locations
        )
    }
    
    private static func generateCacheKey(size: CGSize, style: GradientStyle) -> String {
        let centerHex = style.centerColor.toHexString()
        let edgeHex = style.edgeColor.toHexString()
        return "\(Int(size.width))x\(Int(size.height))_\(centerHex)_\(style.centerAlpha)_\(edgeHex)_\(style.edgeAlpha)"
    }
    
    static func clearCache() {
        imageCache.removeAll()
    }
}

private extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255)
        return String(format: "%06x", rgb)
    }
}
