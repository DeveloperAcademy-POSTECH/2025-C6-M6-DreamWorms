//
//  FontLiterals.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import SwiftUI
import UIKit

enum FontName: String {
    case pretendardBold = "Pretendard-Bold"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardRegular = "Pretendard-Regular"
    case pretendardSemiBold = "Pretendard-SemiBold"
}

extension Font {
    static func pretendardBold(size: CGFloat) -> Font {
        .custom(FontName.pretendardBold.rawValue, size: size)
    }
    
    static func pretendardMedium(size: CGFloat) -> Font {
        .custom(FontName.pretendardMedium.rawValue, size: size)
    }
    
    static func pretendardRegular(size: CGFloat) -> Font {
        .custom(FontName.pretendardRegular.rawValue, size: size)
    }
    
    static func pretendardSemiBold(size: CGFloat) -> Font {
        .custom(FontName.pretendardSemiBold.rawValue, size: size)
    }
}

extension UIFont {
    @nonobjc class func pretendardBold(size: CGFloat) -> UIFont {
        UIFont(name: FontName.pretendardBold.rawValue, size: size)!
    }
    
    @nonobjc class func pretendardMedium(size: CGFloat) -> UIFont {
        UIFont(name: FontName.pretendardMedium.rawValue, size: size)!
    }
    
    @nonobjc class func pretendardRegular(size: CGFloat) -> UIFont {
        UIFont(name: FontName.pretendardRegular.rawValue, size: size)!
    }
    
    @nonobjc class func pretendardSemiBold(size: CGFloat) -> UIFont {
        UIFont(name: FontName.pretendardSemiBold.rawValue, size: size)!
    }
}
