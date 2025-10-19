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
            
            // TODO: Mock View 라서 컨벤션을 못지켰습니다. 추후 MapView 완성 되면 같이 맞추겠습니다. (또는 삭제될 수도)
            VStack(spacing: 12) {
                DWCircleToggleButton(
                    title: "빈도",
                    isOn: $showFrequency
                ) {
                    viewModel.toggleFrequencyMode()
                }
                
                DWCircleToggleButton(
                    title: "반경",
                    isOn: $showCircle
                ) {
                    viewModel.toggleCircleOverlay()
                }
                
                DWCircleToggleButton(
                    title: "갱신",
                    isOn: .constant(false)
                ) {
                    viewModel.loadMockLocations()
                }
            }
            .padding(.top, 124)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print("🗺️ Locations: \(viewModel.locations.count)")
                    print("🗺️ First location: \(viewModel.locations.first?.address ?? "none")")
                }
        }
    }
}

#Preview {
    MockMapView()
}
