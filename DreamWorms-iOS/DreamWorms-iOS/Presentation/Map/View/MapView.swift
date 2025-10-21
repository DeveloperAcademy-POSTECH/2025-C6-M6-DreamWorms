//  MapView.swift

import CoreLocation
import NMapsMap
import SwiftData
import SwiftUI

struct MapView: View {
    let selectedCase: Case
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @StateObject private var viewModel = MapViewModel()
    
    // 전체 데이터 감지용 (변경 감지만 사용)
    @Query(sort: \CaseLocation.receivedAt, order: .reverse)
    private var allCaseLocations: [CaseLocation]
    
    @State private var showFrequency = false
    @State private var showCircle = false
    @State private var showEvidenceBottomSheet: Bool = true
    @State private var evidenceDetent: PresentationDetent = .small
    
    // Case의 locations를 직접 사용
    private var filteredLocations: [CaseLocation] {
        selectedCase.locations
            .filter { $0.latitude != nil && $0.longitude != nil }
            .sorted { $0.receivedAt > $1.receivedAt }
    }
    
    // 실시간 체류 정보
    private var locationStays: [LocationStay] {
        LocationStay.groupByConsecutiveLocation(from: filteredLocations)
    }

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
                MapHeader(
                    onBack: {
                        coordinator.pop()
                    },
                    onSearch: {
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
                onRefresh: { viewModel.refreshData() },
                onCamera: {
                    showEvidenceBottomSheet = false
                    coordinator.push(.reportRecognition)
                }
            )

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
            showEvidenceBottomSheet = true
            
            // 디버깅
            print("\n📋 MapView onAppear")
            print("   - Selected Case: \(selectedCase.name) (ID: \(selectedCase.id))")
            print("   - Direct locations: \(selectedCase.locations.count)")
            print("   - Filtered locations: \(filteredLocations.count)")
            print("   - All CaseLocations: \(allCaseLocations.count)")
            
            // 초기 로드
            viewModel.updateLocations(with: filteredLocations)
        }
        .onDisappear {
            showEvidenceBottomSheet = false
        }
        // 전체 데이터 변경 감지 → Case의 locations 다시 로드
        .onChange(of: allCaseLocations.count) { oldCount, newCount in
            print("\nData changed: \(oldCount) → \(newCount)")
            print("   - Filtered count: \(filteredLocations.count)")
            
            // ViewModel 업데이트
            viewModel.updateLocations(with: filteredLocations)
        }
        .dreamwormsBottomSheet(isPresented: $showEvidenceBottomSheet, detent: $evidenceDetent) {
            EvidenceBottomSheet(
                currentDetent: $evidenceDetent,
                selectedCase: selectedCase,
                totalLocationCount: locationStays.count,
                locationStays: locationStays
            )
        }
    }
}

#Preview {
    MapView(selectedCase: Case(
        name: "베트콩 소탕",
        number: "2024-001",
        suspectName: "왕꿈틀"
    ))
    .environmentObject(AppCoordinator())
}
