//
//  EvidenceBottomSheet.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

/// 지도 위에 올라가는 “증거 정보” 바텀시트 컨테이너
/// - 역할: Small/Medium/Large 단계에 따른 레이아웃 골격만 제공
struct EvidenceBottomSheet: View {
    @Binding var currentDetent: PresentationDetent

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 배경 (시트 내부 전체)
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // 1) 헤더 (항상 노출) — 가로 중앙 정렬
                // TODO: EvidenceHeader 구현 및 교체
                PlaceholderHeader()

                // 2) 탭바 (항상 노출)
                // TODO: EvidenceTabBar로 교체
                Tabs()
                Divider()

                // 3) Medium/Large에서만 날짜 + 리스트
                if currentDetent != .small {
                    // TODO: 실제 날짜 필터 UI로 교체
                    PlaceholderDateFilter()
                    Divider()

                    // TODO: EvidenceList로 교체 (핀 288개까지 스크롤 성능 고려)
                    PlaceholderList()
                }
            }

            // Large 전용 우상단 닫기 버튼 (Float)
            if currentDetent == .large {
                CloseButton {
                    // Large -> Medium으로 내리기
                    currentDetent = .medium
                }
                .padding(.trailing, 16)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Placeholders (임시 뷰: TODO 교체 대상)

/// 헤더(제목만 표시, 가로 중앙)
private struct PlaceholderHeader: View {
    var body: some View {
        Text("증거 정보")
            .font(.system(size: 22, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .center) // ✅ 가운데 정렬
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
}

/// 탭바(항상 노출) — 실제 탭 컴포넌트로 교체 예정
private struct Tabs: View {
    var body: some View {
        HStack(spacing: 16) {
            Text("기지국")
            Text("카드내역")
            Text("차량")
            Text("장소")
        }
        .font(.system(size: 14, weight: .semibold))
        // ✅ 가로 가운데 정렬
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("증거 종류 탭")
    }
}

/// 날짜 필터(미디엄/라지에서만) — 실제 DatePicker/Range UI로 교체 예정
private struct PlaceholderDateFilter: View {
    var body: some View {
        HStack {
            Text("날짜: 2025-10-19 ~ 2025-10-20")
                .font(.system(size: 14, weight: .medium))
            Spacer()
            Image(systemName: "calendar")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

/// 리스트(미디엄/라지에서만) — 실제 EvidenceList로 교체 예정
private struct PlaceholderList: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0 ..< 10) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.12))
                        .frame(height: 56)
                        .overlay(
                            Text("셀 \(i + 1)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                        )
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
    }
}

/// Large 전용 닫기 버튼 (우상단 Float)
private struct CloseButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(Color.gray.opacity(0.15), in: Circle())
        }
        .accessibilityLabel("닫기")
    }
}
