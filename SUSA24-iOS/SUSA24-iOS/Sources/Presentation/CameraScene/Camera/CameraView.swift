//
//  CameraView.swift
//  SUSA24-iOS
//
//  Created by taeni on 10/29/25.
//

import SwiftUI

struct CameraView: View {
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: CameraFeature.State(),
        reducer: CameraFeature()
    )
    
    @State private var camera = CameraModel()
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            CameraPreview(source: camera.previewSource)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CameraHeader(onBackTapped: {}, onScanTapped: {})
                
                Spacer()
                
                CameraController(count: camera.photoCount,  onDetailsTapped: {},onPhotoCaptureTapped: capturePhoto)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await camera.start()
        }
        .onDisappear {
            Task {
                await camera.stop()
            }
        }
    }
}

// MARK: - Extension Methods

extension CameraView {}

// MARK: - Private Extension Methods

private extension CameraView {
    func capturePhoto(){
        Task {
            do {
                _ = try await camera.capturePhoto()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CameraView()
        .environment(AppCoordinator())
}
