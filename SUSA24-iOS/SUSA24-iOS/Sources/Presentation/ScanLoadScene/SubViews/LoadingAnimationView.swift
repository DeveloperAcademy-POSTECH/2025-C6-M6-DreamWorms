//
//  LoadingAnimationView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Combine
import SwiftUI

/// 스캔 진행 중 아이콘 애니메이션 뷰
///
/// - 더 부드럽고 현대적인 로딩 애니메이션
/// - 문서 스캔 느낌의 시각적 피드백
struct LoadingAnimationView: View {
    // MARK: - Constants

    private let containerSize: CGFloat = 120
    private let iconSize: CGFloat = 40

    /// 네 모서리 오프셋 (Top-Left, Top-Right, Bottom-Right, Bottom-Left)
    private static let cornerOffsets: [CGSize] = [
        CGSize(width: -35, height: -35), // Top-Left
        CGSize(width: 35, height: -35), // Top-Right
        CGSize(width: 35, height: 35), // Bottom-Right
        CGSize(width: -35, height: 35), // Bottom-Left
    ]

    /// 순차 경로: 0 -> 1 -> 2 -> 3 -> 0 (시계방향)
    private static let pathIndices: [Int] = [0, 1, 3, 2]

    // MARK: - State

    @State private var currentStepIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    // MARK: - Timer

    private let timer = Timer.publish(every: 1.2, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        ZStack {
            // 배경 문서 이미지 (펄스 효과)
            Image(.imgDoc)
                .resizable()
                .scaledToFit()
                .frame(width: containerSize)
                .scaleEffect(pulseScale)
                .opacity(0.3)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)

            // 스캔 라인 효과
            scanLineEffect

            // 이동 아이콘 (더 부드러운 애니메이션)
            Image(.imgReading)
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(.primaryNormal, .primaryStrong)
                .shadow(color: .primaryNormal.opacity(0.4), radius: 8, x: 0, y: 4)
                .offset(Self.cornerOffsets[Self.pathIndices[currentStepIndex]])
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStepIndex)
                .rotationEffect(.degrees(isAnimating ? 0 : 2))
                .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: isAnimating)
        }
        .frame(width: containerSize, height: containerSize)
        .onAppear {
            isAnimating = true
            pulseScale = 1.1
        }
        .onReceive(timer) { _ in
            currentStepIndex = (currentStepIndex + 1) % Self.pathIndices.count
        }
    }

    // MARK: - Subviews

    /// 스캔 라인
    private var scanLineEffect: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .primaryNormal.opacity(0.3),
                            .clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 2)
                .offset(y: scanLineOffset(in: geometry.size.height))
                .animation(
                    .linear(duration: 2.0).repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .frame(width: containerSize * 1.1, height: containerSize)
    }

    /// 스캔 라인 오프셋 계산
    private func scanLineOffset(in height: CGFloat) -> CGFloat {
        isAnimating ? height : 0
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        LoadingAnimationView()
    }
    .padding(32)
    .background(Color(.systemBackground))
}
