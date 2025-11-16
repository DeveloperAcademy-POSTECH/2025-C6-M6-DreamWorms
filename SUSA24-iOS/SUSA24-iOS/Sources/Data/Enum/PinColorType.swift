import SwiftUI

enum PinColorType: Int16, CaseIterable, Codable {
    case black = 0
    case red = 1
    case orange = 2
    case yellow = 3
    case lightGreen = 4
    case darkGreen = 5
    case purple = 6
    
    init(_ raw: Int16) {
        self = PinColorType(rawValue: raw) ?? .black
    }

    var raw: Int16 { rawValue }
    var color: Color {
        switch self {
        case .black: Color.labelNeutral
        case .red: Color.pointRed2
        case .orange: Color.pinOrange
        case .yellow: Color.pinYellow
        case .lightGreen: Color.pinLightGreen
        case .darkGreen: Color.pinDarkGreen
        case .purple: Color.pointPurple
        }
    }
    
    var pinImage: Image {
        switch self {
        case .black: Image(.pinBlack)
        case .red: Image(.pinRed)
        case .orange: Image(.pinOrange)
        case .yellow: Image(.pinYellow)
        case .lightGreen: Image(.pinLightGreen)
        case .darkGreen: Image(.pinDarkGreen)
        case .purple: Image(.pinPurple)
        }
    }
}
