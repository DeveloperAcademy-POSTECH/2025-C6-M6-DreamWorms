////
////  CameraPreview.swift
////  SUSA24-iOS
////
////  Created by taeni on 11/5/25.
////
//
//
//import SwiftUI
//import AVFoundation
//
//// MARK: - Camera Preview
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//    
//    func makeUIView(context: Context) -> PreviewView {
//        let view = PreviewView()
//        view.session = session
//        return view
//    }
//    
//    func updateUIView(_ uiView: PreviewView, context: Context) {}
//    
//    class PreviewView: UIView {
//        var session: AVCaptureSession? {
//            didSet {
//                guard let session = session else { return }
//                (layer as? AVCaptureVideoPreviewLayer)?.session = session
//            }
//        }
//        
//        override class var layerClass: AnyClass {
//            return AVCaptureVideoPreviewLayer.self
//        }
//    }
//}
//
//// MARK: - Camera Sample View
//struct CameraSampleView: View {
//    @StateObject private var imageManager = CameraImageManager()
//    @State private var cameraService: CameraService?
//    @State private var isLoading = false
//    @State private var showError = false
//    @State private var errorMessage = ""
//    @State private var tapLocation: CGPoint?
//    
//    var body: some View {
//        ZStack {
//            // 카메라 프리뷰
//            if let session = cameraService?.session {
//                CameraPreview(session: session)
//                    .ignoresSafeArea()
//                    .onTapGesture { location in
////                        handleTapFocus(at: location)
//                    }
//            } else {
//                Color.black.ignoresSafeArea()
//            }
//            
//            VStack {
//                // 헤더
//                HStack {
//                    Text("카메라")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                    
//                    Spacer()
//                    
//                    if isLoading {
//                        ProgressView()
//                            .tint(.white)
//                    }
//                }
//                .padding()
//                .background(Color.black.opacity(0.3))
//                
//                Spacer()
//                
//                // 하단 컨트롤
//                VStack(spacing: 16) {
//                    HStack(spacing: 12) {
//                        // 자동 포커스 버튼
////                        Button(action: autoFocusCenter) {
////                            Image(systemName: "scope")
////                                .font(.system(size: 20))
////                                .foregroundColor(.white)
////                                .padding(12)
////                                .background(Color.blue)
////                                .clipShape(Circle())
////                        }
////                        .disabled(isLoading)
//                        
//                        Spacer()
//                        
//                        // 촬영 버튼
//                        Button(action: capturePhoto) {
//                            Image(systemName: "camera.circle.fill")
//                                .font(.system(size: 60))
//                                .foregroundColor(.white)
//                        }
//                        .disabled(isLoading)
//                        
//                        Spacer()
//                        
//                        // 이미지 목록 버튼
//                        Button(action: {}) {
//                            ZStack(alignment: .topTrailing) {
//                                Image(systemName: "photo.stack")
//                                    .font(.system(size: 20))
//                                    .foregroundColor(.white)
//                                    .padding(12)
//                                    .background(Color.gray)
//                                    .clipShape(Circle())
//                                
//                                if imageManager.images.count > 0 {
//                                    Text("\(imageManager.images.count)")
//                                        .font(.caption2)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(.white)
//                                        .background(Color.red)
//                                        .clipShape(Circle())
//                                        .frame(width: 20, height: 20)
//                                        .offset(x: 4, y: -4)
//                                }
//                            }
//                        }
//                        .disabled(isLoading)
//                    }
//                    .padding(.horizontal)
//                    
//                    // 최신 이미지 썸네일
//                    if let lastImage = imageManager.lastImage {
//                        HStack {
//                            Image(uiImage: lastImage)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 80, height: 80)
//                                .cornerRadius(8)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .stroke(Color.white, lineWidth: 2)
//                                )
//                            
//                            Spacer()
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//                .padding()
//                .background(Color.black.opacity(0.4))
//            }
//            
//            // 탭 포커스 인디케이터
//            if let tapLocation = tapLocation {
//                Circle()
//                    .stroke(Color.yellow, lineWidth: 2)
//                    .frame(width: 60, height: 60)
//                    .position(tapLocation)
//                    .transition(.scale)
//            }
//        }
//        .alert("오류", isPresented: $showError) {
//            Button("확인", role: .cancel) {}
//        } message: {
//            Text(errorMessage)
//        }
//        .onAppear {
//            initializeCamera()
//        }
//        .onDisappear {
//            stopCamera()
//        }
//    }
//    
//    // MARK: - Private Methods
//    private func initializeCamera() {
//        Task {
//            let authorized = await CameraAuthorizationManager.shared.requestCameraAccess()
//            guard authorized else {
//                errorMessage = "카메라 접근 권한이 없습니다."
//                showError = true
//                return
//            }
//            
//            let service = CameraService()
//            do {
//                try await service.configure()
////                try await service.configureForHighQuality()
//                self.cameraService = service
//            } catch {
//                errorMessage = error.localizedDescription
//                showError = true
//            }
//        }
//    }
//    
//    private func stopCamera() {
//        Task {
//            await cameraService?.stop()
//        }
//    }
//    
//    private func capturePhoto() {
//        guard let cameraService = cameraService else { return }
//        
//        isLoading = true
//        Task {
//            do {
//                let photoData = try await cameraService.capturePhoto()
//                
//                if let uiImage = UIImage(data: photoData) {
//                    await MainActor.run {
//                        imageManager.addImage(uiImage)
//                        isLoading = false
//                    }
//                }
//            } catch {
//                await MainActor.run {
//                    errorMessage = "사진 촬영에 실패했습니다: \(error.localizedDescription)"
//                    showError = true
//                    isLoading = false
//                }
//            }
//        }
//    }
//    
////    private func autoFocusCenter() {
////        guard let cameraService = cameraService else { return }
////        
////        Task {
////            do {
////                if let device = await cameraService.getVideoDevice() {
////                    try cameraService.setAutoFocusToCenterAndExpose(on: device)
////                }
////            } catch {
////                errorMessage = "중앙 포커스 설정 실패"
////                showError = true
////            }
////        }
////    }
//}
//
//// MARK: - Preview
//#Preview {
//    CameraSampleView()
//}
