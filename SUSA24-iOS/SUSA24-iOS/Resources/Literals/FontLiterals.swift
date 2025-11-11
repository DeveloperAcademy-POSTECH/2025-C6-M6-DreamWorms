//
//  FontLiterals.swift
//  SUSA24-iOS
//
//  Created by mini on 10/30/25.
//

import SwiftUI
import UIKit

// MARK: - FontName Enum

enum FontName: String {
    case notoSansMedium = "NotoSansKR-Medium"
    case notoSansRegular = "NotoSansKR-Regular"
    case notoSansSemiBold = "NotoSansKR-SemiBold"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardRegular = "Pretendard-Regular"
    case pretendardSemiBold = "Pretendard-SemiBold"
}

// MARK: - Font Extension

extension Font {
    // MARK: - Title
    
    static let titleSemiBold22: Font = .custom(FontName.notoSansSemiBold.rawValue, size: 22)
    static let titleSemiBold20: Font = .custom(FontName.notoSansSemiBold.rawValue, size: 20)
    static let titleSemiBold18: Font = .custom(FontName.notoSansSemiBold.rawValue, size: 18)
    static let titleSemiBold16: Font = .custom(FontName.notoSansSemiBold.rawValue, size: 16)
    static let titleSemiBold14: Font = .custom(FontName.notoSansSemiBold.rawValue, size: 14)

    // MARK: - Body
    
    static let bodyMedium16: Font = .custom(FontName.notoSansMedium.rawValue, size: 16)
    static let bodyMedium14: Font = .custom(FontName.notoSansMedium.rawValue, size: 14)
    static let bodyRegular14: Font = .custom(FontName.notoSansRegular.rawValue, size: 14)
    static let bodyMedium12: Font = .custom(FontName.notoSansMedium.rawValue, size: 12)
    static let bodyMedium10: Font = .custom(FontName.notoSansMedium.rawValue, size: 10)

    // MARK: - Caption
    
    static let captionRegular13: Font = .custom(FontName.notoSansRegular.rawValue, size: 13)
    static let captionRegular12: Font = .custom(FontName.notoSansRegular.rawValue, size: 12)

    // MARK: - Number

    static let numberMedium16: Font = .custom(FontName.pretendardMedium.rawValue, size: 16)
    static let numberMedium15: Font = .custom(FontName.pretendardMedium.rawValue, size: 15)
    static let numberRegular15: Font = .custom(FontName.pretendardRegular.rawValue, size: 15)
    static let numberSemiBold14: Font = .custom(FontName.pretendardSemiBold.rawValue, size: 14)
    static let numberMedium12: Font = .custom(FontName.pretendardMedium.rawValue, size: 12)
}

// MARK: - UIFont Extension

extension UIFont {
    // MARK: - Title
    
    static let titleSemiBold22: UIFont = .custom(.notoSansSemiBold, size: 22)
    static let titleSemiBold20: UIFont = .custom(.notoSansSemiBold, size: 20)
    static let titleSemiBold18: UIFont = .custom(.notoSansSemiBold, size: 18)
    static let titleSemiBold16: UIFont = .custom(.notoSansSemiBold, size: 16)
    static let titleSemiBold14: UIFont = .custom(.notoSansSemiBold, size: 14)
    
    // MARK: - Body
    
    static let bodyMedium16: UIFont = .custom(.notoSansMedium, size: 16)
    static let bodyMedium14: UIFont = .custom(.notoSansMedium, size: 14)
    static let bodyRegular14: UIFont = .custom(.notoSansRegular, size: 14)
    static let bodyMedium12: UIFont = .custom(.notoSansMedium, size: 12)
    
    // MARK: - Caption
    
    static let captionRegular13: UIFont = .custom(.notoSansRegular, size: 13)
    static let captionRegular12: UIFont = .custom(.notoSansRegular, size: 12)
    
    // MARK: - Number
    
    static let numberMedium16: UIFont = .custom(.pretendardMedium, size: 16)
    static let numberMedium15: UIFont = .custom(.pretendardMedium, size: 15)
    static let numberRegular15: UIFont = .custom(.pretendardRegular, size: 15)
    static let numberSemiBold14: UIFont = .custom(.pretendardSemiBold, size: 14)
    static let numberMedium12: UIFont = .custom(.pretendardMedium, size: 12)
}

// MARK: - UIFont Private Extension

private extension UIFont {
    static func custom(_ name: FontName, size: CGFloat) -> UIFont {
        UIFont(name: name.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
}
