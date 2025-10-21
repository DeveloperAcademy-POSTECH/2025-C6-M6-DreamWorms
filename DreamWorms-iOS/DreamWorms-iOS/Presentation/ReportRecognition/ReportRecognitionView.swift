//
//  ReportRecognitionView.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/21/25.
//

import AVFoundation
import CoreLocation
import SwiftData
import SwiftUI

@available(iOS 18.0, *)
struct ReportRecognitionView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.modelContext) private var modelContext

    @State private var camera = CameraModel()
    @State private var isProcessing = false

    @State private var showFlash = false
    @State private var shutterProgress: CGFloat = 0

    var body: some View {
        ZStack {
            FrameView(image: camera.frame)
                .ignoresSafeArea()

            Color.black.opacity(0.6)
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .frame(
                                    width: UIScreen.main.bounds.width - 40,
                                    height: UIScreen.main.bounds.height * 0.58
                                )
                                .blendMode(.destinationOut)
                        )
                )
                .compositingGroup()

            VStack(spacing: 0) {
                Spacer().frame(height: 120)
                Text("보고서를 사각형에 맞게 놓아주세요")
                    .font(.pretendardRegular(size: 14))
                    .foregroundColor(.white)
                    .padding(.bottom, 28)
                Spacer()
            }

            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(1), lineWidth: 3)
                .frame(
                    width: UIScreen.main.bounds.width - 40,
                    height: UIScreen.main.bounds.height * 0.58
                )
                .allowsHitTesting(false)

            VStack {
                Spacer()
                Button(action: {
                    triggerShutterAnimation()
                    onTapCapture()
                }) {
                    Text("촬영하기")
                        .font(.pretendardSemiBold(size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(.black22)
                        .foregroundColor(.white)
                }
            }

            ShutterOverlay(showFlash: showFlash, shutterProgress: shutterProgress)
                .allowsHitTesting(false)
        }
        .navigationTitle("보고서 스캔")
        .navigationBarTitleDisplayMode(.inline)
        .task { await camera.start() }
    }

    // MARK: - Actions

    private func onTapCapture() {
        isProcessing = true
        Task {
            do {
                let (fullText, addresses) = try await camera.recognizeAddressesFromCurrentFrame()
                print("인식 텍스트(발췌):\n\(fullText.prefix(300))…")

                guard let rawAddress = addresses.first else {
                    isProcessing = false
                    print("주소를 찾지 못했습니다.")
                    return
                }

                print("📍 추출 주소 후보:", rawAddress)

                let geocode = try await GeocodeService.geocode(address: rawAddress)

                await MainActor.run {
                    do {
                        guard let activeCase = try? fetchActiveCase(from: modelContext) else {
                            print("❌ activeCase 없음 — 저장 스킵")
                            isProcessing = false
                            return
                        }

                        let location = CaseLocation(
                            pinType: .report,
                            address: geocode.fullAddress,
                            latitude: geocode.latitude,
                            longitude: geocode.longitude,
                            receivedAt: Date().toKoreanTime
                        )
                        location.parentCase = activeCase
                        modelContext.insert(location)

                        try modelContext.save()
                        print("""
                        저장 완료
                           - Address: \(geocode.fullAddress)
                           - Coords: \(geocode.latitude?.description ?? "nil"), \(geocode.longitude?.description ?? "nil")
                           - Case: \(activeCase.name)
                        """)

                        isProcessing = false
                        coordinator.pop()
                    } catch {
                        isProcessing = false
                        print("❌ 저장 실패: \(error)")
                    }
                }
            } catch {
                isProcessing = false
                print("❌ 인식/지오코딩 실패: \(error)")
            }
        }
    }
    
    @MainActor
    private func fetchActiveCase(from context: ModelContext) throws -> DreamWorms_iOS.Case? {
        if let idString = UserDefaults.standard.string(forKey: "activeCase"),
           let activeCaseID = UUID(uuidString: idString)
        {
            let descriptor = FetchDescriptor<DreamWorms_iOS.Case>(
                predicate: #Predicate { $0.id == activeCaseID }
            )
            return try context.fetch(descriptor).first
        } else {
            print("ActiveCase 미설정 → 첫 번째 Case 사용 시도")
            let all = try context.fetch(FetchDescriptor<DreamWorms_iOS.Case>())
            return all.first
        }
    }

    // MARK: - Shutter Animation

    private func triggerShutterAnimation() {
        triggerMediumHapticFeedback()
        
        withAnimation(.easeOut(duration: 0.08)) {
            shutterProgress = 1
        }
        withAnimation(.easeIn(duration: 0.12).delay(0.06)) {
            shutterProgress = 0
        }

        showFlash = true
        withAnimation(.easeOut(duration: 0.12)) {
            showFlash = false
        }
    }
}

// MARK: - Shutter Overlay (블레이드 + 플래시)

private struct ShutterOverlay: View {
    let showFlash: Bool
    let shutterProgress: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // 블레이드: 위/아래에서 중앙으로 닫혔다 열림
                let halfH = proxy.size.height / 2
                let bladeH = halfH * shutterProgress

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.black.opacity(0.35))
                        .frame(height: bladeH)
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(.black.opacity(0.35))
                        .frame(height: bladeH)
                }
                .animation(.none, value: shutterProgress)

                Color.white
                    .opacity(showFlash ? 0.85 : 0)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Preview Layer Wrapper

struct FrameView: UIViewRepresentable {
    let image: Any?
    var gravity = CALayerContentsGravity.resizeAspectFill

    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        view.layer.contentsGravity = gravity
        return view
    }

    func updateUIView(_ uiView: UIView, context _: Context) {
        uiView.layer.contents = image
    }
}
