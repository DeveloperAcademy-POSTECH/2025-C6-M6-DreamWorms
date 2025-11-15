//
//  MapPreviewView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/15/25.
//

import SwiftUI

struct MapPreviewView: View {
    let centerCoordinate: MapCoordinate
    let locations: [Location]
    
    @Binding var isExpanded: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            OverviewNaverMapView(
                centerCoordinate: centerCoordinate,
                locations: locations
            )
            .frame(height: 206)
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .matchedGeometryEffect(id: "overviewMap", in: namespace)

            Button {
                withAnimation(
                    .spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.15)
                ) {
                    isExpanded = true
                }
            } label: {
                Image(.expand)
                    .font(.system(size: 17, weight: .regular))
                    .padding(6)
                    .background(.labelNeutral.opacity(0.35))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(12)
        }
    }
}
