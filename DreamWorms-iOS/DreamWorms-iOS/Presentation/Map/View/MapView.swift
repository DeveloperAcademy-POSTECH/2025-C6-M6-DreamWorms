//
//  MapView.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/17/25.
//

import CoreLocation
import NMapsMap
import SwiftData
import SwiftUI

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @StateObject private var viewModel = MapViewModel()
    
    @State private var showFrequency = false
    @State private var showCircle = false
    
    // 바텀시트 관련 상태
    @State private var showEvidenceBottomSheet: Bool = true
    @State private var evidenceDetent: PresentationDetent = .small
    // 데모용(실제로는 선택된 사건 전달)
    @State private var selectedCaseForSheet: Case = .init(
        name: "베트콩 소탕", number: "2024-001", suspectName: "왕꿈틀"
    )
    private let locationAmount: Int = 39

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
                    evidenceDetent = .medium
                },
                onMapTap: { _ in
                    evidenceDetent = .medium
                }
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 검색 헤더
                MapHeader(
                    onBack: {
                        coordinator.pop()
                    },
                    onSearch: {
                        // SearchView로 네비게이션
                        coordinator.push(.search)
                    }
                )
                
                Spacer()
            }
            
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
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.loadAllLocations()
            showEvidenceBottomSheet = true
        }
        .dreamwormsBottomSheet(isPresented: $showEvidenceBottomSheet, detent: $evidenceDetent) {
            EvidenceBottomSheet(
                currentDetent: $evidenceDetent,
                selectedCase: selectedCaseForSheet,
                totalLocationCount: locationAmount,
                evidences: Evidence.mockData
            )
        }
    }
}

#Preview {
    MapView()
}
