//
//  MockMapView.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/19/25.
//


import SwiftUI
import NMapsMap
import CoreLocation

struct MockMapView: View {
    @StateObject private var viewModel = MapViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var showFrequency = false
    @State private var showCircle = false
    
    var body: some View {
        ZStack {
            NaverMapView(
                cameraPosition: $viewModel.cameraPosition,
                configuration: NaverMapConfiguration(
                    clusteringEnabled: viewModel.clusteringEnabled
                ),
                displayMode: viewModel.displayMode,
                overlayOptions: viewModel.overlayOptions,
                locations: viewModel.locations,
                onMarkerTap: { markerData in
                    print("Marker tapped: \(markerData.title)")
                }
            )
            .ignoresSafeArea()
            
            
            MapControlPanel(
                showFrequency: $showFrequency,
                showCircle: $showCircle,
                isClusteringEnabled: viewModel.clusteringEnabled,
                onToggleFrequency: { viewModel.toggleFrequencyMode() },
                onToggleCircle: { viewModel.toggleCircleOverlay() },
                onRefresh: { viewModel.refreshData() }
            )
            
            // 토글 기능이 없는 버튼임
            // TODO: 추후 컴포넌트 수정
            DWCircleToggleButton(
                systemImage: "scope",
                isOn: .constant(false)
            ) {
                viewModel.moveToMyLocation()
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .onAppear {
            viewModel.loadMockLocations()
        }
    }
}

#Preview {
    MockMapView()
}
