//
//  CameraSampleView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import SwiftUI

/// 카메라 기능의 기본 동작을 보여주는 간단한 샘플 뷰
struct CameraSampleView: View {
    @State private var camera = CameraModel()
    @State private var statusMessage = "준비 중..."
    
    var body: some View {
        ZStack {
            // MARK: - 카메라 프리뷰

            CameraPreview(source: camera.previewSource)
            
            VStack {
                // MARK: - 상단: 상태 표시

                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("사진")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(camera.photoCount)/10")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.4))
                .cornerRadius(8)
                .padding(16)
                
                Spacer()
                
                // MARK: - 하단: 컨트롤 버튼

                HStack(spacing: 12) {
                    // 토치 버튼
                    DWCircleButton(image: Image(systemName: camera.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill"), action: { Task { await camera.toggleTorch() } })
                    
                    Spacer()
                    // 촬영 버튼
                    DWCircleButton(image: Image(.camera), action: capturePhoto)
                        .disabled(camera.photoCount >= 10 || camera.cameraStatus != .running)
                    
                    Spacer()
                    
                    // 초기화 버튼
                    DWCircleButton(image: Image(.delete), action: camera.clearAllPhotos)
                 }
                .padding(16)
            }
            .padding(16)
            
            // MARK: - 좌측 하단: 마지막 썸네일

            VStack {
                Spacer()
                
                HStack {
                    if let thumbnail = camera.lastThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    
                    Spacer()
                }
                .padding(12)
            }
            .padding(16)
        }
        .ignoresSafeArea()
        .task {
            await camera.start()
        }
        .onDisappear {
            Task {
                await camera.stop()
            }
        }
    }
    
    // MARK: - 촬영 함수

    private func capturePhoto() {
        Task {
            do {
                _ = try await camera.capturePhoto()
                statusMessage = "사진 촬영됨 (\(camera.photoCount)/10)"
            } catch {
                statusMessage = "촬영 실패: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Preview

// #Preview {
//    CameraSampleView()
// }
