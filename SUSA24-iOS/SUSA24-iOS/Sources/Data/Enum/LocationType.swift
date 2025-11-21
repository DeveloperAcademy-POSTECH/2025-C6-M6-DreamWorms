import SwiftUI

enum LocationType: Int16, Codable {
    case home = 0
    case work = 1
    case cell = 2
    case custom = 3
    
    init(_ raw: Int16) {
        self = LocationType(rawValue: raw) ?? .custom
    }

    var raw: Int16 { rawValue }
    var icon: Image {
        switch self {
        case .home: Image(.icnHome)
        case .work: Image(.icnCrime)
        case .cell: Image(.icnCellStationFilter)
        case .custom: Image(.icnPin)
        }
    }
}
