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
    
    let cctvMarkers: [CCTVMarker]
    let isCCTVLoading: Bool
    
    let namespace: Namespace.ID
    let onBack: () -> Void
    
    @State private var isMapExpanded: Bool = false
    @State private var isShareSheetPresented: Bool = false
    
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
                    
                    Text(.trackingNavigationTitle)
                        .font(.titleSemiBold16)
                        .foregroundStyle(.labelNormal)
                    
                    Spacer()
                    
                    DWGlassEffectCircleButton(
                        image: Image(.share),
                        action: { isShareSheetPresented = true }
                    )
                    .setupSize(44)
                    .setupIconSize(18)
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                
                TrackingResultMapPreview(
                    locations: locations,
                    selectedLocationIDs: selectedLocationIDs,
                    cctvMarkers: cctvMarkers,
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
                
                Text("\(.trackingResultSectionTitle) (\(cctvMarkers.count))")
                    .font(.titleSemiBold18)
                    .foregroundStyle(.labelNormal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                if isCCTVLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if cctvMarkers.isEmpty {
                    TimeLineEmptyState(message: .cctvEmpty)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(cctvMarkers) { item in
                                DWLocationCard(
                                    type: .cctv,
                                    title: item.name,
                                    description: "\(item.location), \(item.id)"
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
                    cctvMarkers: cctvMarkers,
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
        .sheet(isPresented: $isShareSheetPresented) {
            ActivityView(activityItems: shareActivityItems)
        }
    }
}

struct TrackingResultMapPreview: View {
    let locations: [Location]
    let selectedLocationIDs: Set<UUID>
    let cctvMarkers: [CCTVMarker]
    let namespace: Namespace.ID
    let onExpand: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TrackingNaverMapView(
                locations: locations,
                selectedLocationIDs: selectedLocationIDs,
                cctvMarkers: cctvMarkers,
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
    let cctvMarkers: [CCTVMarker]
    let namespace: Namespace.ID
    let onCollapse: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TrackingNaverMapView(
                locations: locations,
                selectedLocationIDs: selectedLocationIDs,
                cctvMarkers: cctvMarkers,
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

private extension TrackingResultScreen {
    /// 공유 시 사용할 CCTV 요약 텍스트
    var cctvShareText: String {
        guard !cctvMarkers.isEmpty else {
            return "[CCTV 캔버스]\n공유할 CCTV 정보가 없습니다."
        }
        
        var lines: [String] = []
        lines.append(
            """
            [CCTV 캔버스]
            
            선택한 영역 내 CCTV
            총 개수: \(cctvMarkers.count)개
            """
        )
        
        for (index, marker) in cctvMarkers.enumerated() {
            let name = marker.name
            let location = marker.location
            let idDescription = marker.id
            
            lines.append(
                """
                [\(index + 1)]
                이름: \(name)
                위치: \(location)
                CCTV ID: \(idDescription)
                """
            )
        }
        
        return lines.joined(separator: "\n\n")
    }
    
    /// Share Sheet에 넘길 activityItems
    private var shareActivityItems: [Any] {
        [cctvShareText]
    }
}
