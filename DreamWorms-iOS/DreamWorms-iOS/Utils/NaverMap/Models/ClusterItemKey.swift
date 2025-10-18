//
//  ClusterKey.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/18/25.
//

import Foundation
import NMapsMap

public class ClusterItemKey: NSObject, NMCClusteringKey, NSCopying {
    public let identifier: Int
    public let position: NMGLatLng

    public init(identifier: Int, position: NMGLatLng) {
        self.identifier = identifier
        self.position = position
    }

    public var clusteringPosition: NMGLatLng {
        return position
    }

    public nonisolated override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ClusterItemKey else { return false }
        return self.identifier == other.identifier
    }

    public nonisolated override var hash: Int {
        return identifier
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return ClusterItemKey(identifier: self.identifier, position: self.position)
    }
}
