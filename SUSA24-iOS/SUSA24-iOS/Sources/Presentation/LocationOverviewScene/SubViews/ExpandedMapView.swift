//
//  ExpandedMapView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/15/25.
//

import SwiftUI

struct ExpandedMapView: View {
    let centerCoordinate: MapCoordinate
    let locations: [Location]
    
    @Binding var isExpanded: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            OverviewNaverMapView(
                centerCoordinate: centerCoordinate,
                locations: locations
            )
            .ignoresSafeArea(.container, edges: .bottom)
            .matchedGeometryEffect(id: "overviewMap", in: namespace)
            
            DWGlassEffectCircleButton(
                image: Image(.xmark)
            ) {
                withAnimation(
                    .spring(response: 0.45, dampingFraction: 0.9, blendDuration: 0.15)
                ) {
                    isExpanded = false
                }
            }
            .padding(16)
        }
    }
}
