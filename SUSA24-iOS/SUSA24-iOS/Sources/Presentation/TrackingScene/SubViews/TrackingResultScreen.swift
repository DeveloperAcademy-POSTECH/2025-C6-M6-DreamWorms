//
//  TrackingResultScreen.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct TrackingResultScreen: View {
    let locations: [Location]
    let selectedLocationIDs: Set<UUID>
    let slots: [String?]
    let cctvItems: [CCTVItem]
    let isCCTVLoading: Bool
    
    let namespace: Namespace.ID
    let onBack: () -> Void

    @State private var isMapExpanded: Bool = false
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    DWGlassEffectCircleButton(
                        image: Image(.back),
                        action: onBack
                    )
                    .setupSize(44)
                    .setupIconSize(18)
                    
                    Spacer()
                    
                    Text(.trackingResultNavigationTitle)
                        .font(.titleSemiBold16)
                        .foregroundStyle(.labelNormal)
                    
                    Spacer()
                    
                    DWGlassEffectCircleButton(
                        image: Image(.share),
                        action: {
                            // TODO: - 공유 액션
                        }
                    )
                    .setupSize(44)
                    .setupIconSize(18)
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                
                TrackingResultMapPreview(
                    locations: locations,
                    selectedLocationIDs: selectedLocationIDs,
                    namespace: namespace,
                    onExpand: {
                        withAnimation(
                            .spring(response: 0.45,
                                    dampingFraction: 0.82,
                                    blendDuration: 0.15)
                        ) {
                            isMapExpanded = true
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 26)
                .padding(.bottom, 24)
                
                Text(.trackingResultSectionTitle)
                    .font(.titleSemiBold18)
                    .foregroundStyle(.labelNormal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                if isCCTVLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(cctvItems) { item in
                                DWLocationCard(
                                    type: .cctv,
                                    title: item.name,
                                    description: item.address
                                )
                                .setupAsButton(false)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 90)
                    }
                }
            }
            
            if isMapExpanded {
                TrackingResultExpandedMapView(
                    locations: locations,
                    selectedLocationIDs: selectedLocationIDs,
                    namespace: namespace,
                    onCollapse: {
                        withAnimation(
                            .spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.15)
                        ) {
                            isMapExpanded = false
                        }
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .opacity
                    )
                )
                .zIndex(10)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TrackingResultMapPreview: View {
    let locations: [Location]
    let selectedLocationIDs: Set<UUID>
    let namespace: Namespace.ID
    let onExpand: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TrackingNaverMapView(
                locations: locations,
                selectedLocationIDs: selectedLocationIDs,
                onLocationTapped: { _, _ in }
            )
            .matchedGeometryEffect(id: "trackingMap", in: namespace)
            .frame(height: 206)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            Button(action: onExpand) {
                Image(.expand)
                    .font(.system(size: 17, weight: .regular))
                    .padding(6)
                    .background(.labelNeutral.opacity(0.35))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(10)
        }
    }
}

struct TrackingResultExpandedMapView: View {
    let locations: [Location]
    let selectedLocationIDs: Set<UUID>
    let namespace: Namespace.ID
    let onCollapse: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TrackingNaverMapView(
                locations: locations,
                selectedLocationIDs: selectedLocationIDs,
                onLocationTapped: { _, _ in }
            )
            .matchedGeometryEffect(id: "trackingMap", in: namespace)
            .ignoresSafeArea()
            
            Button(action: onCollapse) {
                Image(.xmark)
                    .font(.system(size: 17, weight: .regular))
                    .padding(8)
                    .background(.labelNeutral.opacity(0.35))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 54)
            .padding(.trailing, 16)
        }
    }
}
