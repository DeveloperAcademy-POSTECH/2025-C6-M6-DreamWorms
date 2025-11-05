/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Provides a bounding box around a NormalizedRegion that can be used in a SwiftUI View.
*/

import SwiftUI
import Vision

struct BoundingBox: Shape {
    let region: NormalizedRegion
    
    func path(in rect: CGRect) -> Path {
        let scale = CGSize(width: rect.width, height: rect.height)
        // Convert points in Vision's coordinate system to SwiftUI coordinates.
        let points = region.points.map { $0.toImageCoordinates(scale, origin: .upperLeft) }
        
        return Path { path in
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
    }
}
