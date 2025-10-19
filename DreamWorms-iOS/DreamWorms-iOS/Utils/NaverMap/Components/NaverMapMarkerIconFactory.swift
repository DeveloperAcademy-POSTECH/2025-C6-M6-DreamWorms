//
//  NaverMapMarkerIconFactory.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/19/25.
//
import UIKit
import NMapsMap
import SwiftUI

// TODO: 추후 따로 분리해서 고도화 할 예정
enum MarkerIconType {
    case symbol(name: String, color: UIColor = .systemBlue, background: UIColor = .white, stroke: UIColor = UIColor(Color.white), width: CGFloat = 16, height: CGFloat = 16)
    case number(Int, textColor: UIColor = .white, background: UIColor = .systemBlue, stroke: UIColor = .white)
    case text(String, textColor: UIColor = .white, background: UIColor = .systemGreen, stroke: UIColor = .white)
    case customImage(UIImage)
}

struct NaverMapMarkerIconFactory {
    // TODO: 마커 상수 처리 수정 요망
    private static let markerSize: CGFloat = 24
    private static let strokeWidth: CGFloat = 1.0
    
    static func create(_ type: MarkerIconType) -> NMFOverlayImage? {
        switch type {
        case let .symbol(name, color, background, stroke, width, height):
            return createSymbolIcon(name: name, color: color, background: background, stroke: stroke, width: width, height: height)
            
        case let .number(value, textColor, background, stroke):
            return createNumberIcon(value: value, textColor: textColor, background: background, stroke: stroke)
            
        case let .text(text, textColor, background, stroke):
            return createTextIcon(text: text, textColor: textColor, background: background, stroke: stroke)
            
        case let .customImage(image):
            return NMFOverlayImage(image: image)
        }
    }
}

private extension NaverMapMarkerIconFactory {
    
    static func createSymbolIcon(name: String, color: UIColor, background: UIColor, stroke: UIColor, width: CGFloat, height: CGFloat) -> NMFOverlayImage? {
        let containerSize = markerSize
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: containerSize, height: containerSize))
        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
            let insetRect = rect.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)
            
            let backgroundPath = UIBezierPath(ovalIn: insetRect)
            background.setFill()
            backgroundPath.fill()
            
            stroke.setStroke()
            backgroundPath.lineWidth = strokeWidth
            backgroundPath.stroke()
            
            let config = UIImage.SymbolConfiguration(pointSize: max(width, height), weight: .medium)
            if let symbol = UIImage(systemName: name, withConfiguration: config) {
                let targetSize = CGSize(width: width, height: height)
                
                let renderer = UIGraphicsImageRenderer(size: targetSize)
                let resizedSymbol = renderer.image { _ in
                    symbol.draw(in: CGRect(origin: .zero, size: targetSize))
                }
                
                let x = (containerSize - width) / 2
                let y = (containerSize - height) / 2
                
                resizedSymbol.withTintColor(color, renderingMode: .alwaysOriginal)
                    .draw(in: CGRect(x: x, y: y, width: width, height: height))
            }
        }
        
        return NMFOverlayImage(image: image)
    }
    
    // TODO: containerSize 상수 처리 수정 요망
    static func createNumberIcon(value: Int, textColor: UIColor, background: UIColor, stroke: UIColor) -> NMFOverlayImage? {
        let containerSize = CGFloat(26)
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: containerSize, height: containerSize))
        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
            let insetRect = rect.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)
            
            let circlePath = UIBezierPath(ovalIn: insetRect)
            background.setFill()
            circlePath.fill()
            
            stroke.setStroke()
            circlePath.lineWidth = strokeWidth
            circlePath.stroke()
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 10),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let text = "\(value)" as NSString
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (containerSize - textSize.width) / 2,
                y: (containerSize - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return NMFOverlayImage(image: image)
    }
    
    static func createTextIcon(text: String, textColor: UIColor, background: UIColor, stroke: UIColor) -> NMFOverlayImage? {
        let containerSize = markerSize
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: containerSize, height: containerSize))
        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
            let insetRect = rect.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)
            
            let circlePath = UIBezierPath(ovalIn: insetRect)
            background.setFill()
            circlePath.fill()
            
            stroke.setStroke()
            circlePath.lineWidth = strokeWidth
            circlePath.stroke()
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let nsText = text as NSString
            let textSize = nsText.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (containerSize - textSize.width) / 2,
                y: (containerSize - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            nsText.draw(in: textRect, withAttributes: attributes)
        }
        
        return NMFOverlayImage(image: image)
    }
}

// TODO: 추후 따로 분리해서 사용
private extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
