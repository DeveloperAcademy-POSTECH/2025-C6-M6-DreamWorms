//
//  ClusterItemKey.swift
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
        position
    }

    override public nonisolated func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ClusterItemKey else { return false }
        return identifier == other.identifier
    }

    override public nonisolated var hash: Int {
        identifier
    }

    public func copy(with _: NSZone? = nil) -> Any {
        ClusterItemKey(identifier: identifier, position: position)
    }
}
