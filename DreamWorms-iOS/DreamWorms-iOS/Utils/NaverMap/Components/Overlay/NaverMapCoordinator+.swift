//
//  NaverMapCoordinator+.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/20/25.
//

import Foundation
import NMapsMap

extension NaverMapCoordinator {
    var groundOverlays: [NMFGroundOverlay] {
        get {
            if let overlays = objc_getAssociatedObject(self, &AssociatedKeys.groundOverlays) as? [NMFGroundOverlay] {
                return overlays
            }
            let overlays: [NMFGroundOverlay] = []
            objc_setAssociatedObject(self, &AssociatedKeys.groundOverlays, overlays, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return overlays
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.groundOverlays, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var circleOverlays: [NMFCircleOverlay] {
        get {
            if let overlays = objc_getAssociatedObject(self, &AssociatedKeys.circleOverlays) as? [NMFCircleOverlay] {
                return overlays
            }
            let overlays: [NMFCircleOverlay] = []
            objc_setAssociatedObject(self, &AssociatedKeys.circleOverlays, overlays, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return overlays
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.circleOverlays, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var pathOverlay: NMFPath? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.pathOverlay) as? NMFPath
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pathOverlay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var arrowPathOverlay: NMFArrowheadPath? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.arrowPathOverlay) as? NMFArrowheadPath
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.arrowPathOverlay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func clearGroundOverlays() {
        for overlay in groundOverlays {
            overlay.mapView = nil
        }
        groundOverlays.removeAll()
    }
    
    func clearCircleOverlays() {
        for overlay in circleOverlays {
            overlay.mapView = nil
        }
        circleOverlays.removeAll()
    }
    
    func clearAll() {
        clearGroundOverlays()
        clearCircleOverlays()
        pathOverlay?.mapView = nil
        pathOverlay = nil
        arrowPathOverlay?.mapView = nil
        arrowPathOverlay = nil
    }
}

private enum AssociatedKeys {
    static var groundOverlays: UInt8 = 0
    static var circleOverlays: UInt8 = 1
    static var pathOverlay: UInt8 = 2
    static var arrowPathOverlay: UInt8 = 3
}
