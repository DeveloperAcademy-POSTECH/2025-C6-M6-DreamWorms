//
//  OnePageView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

// MARK: - Models

enum Category: String, CaseIterable, Identifiable {
    case all, residence, workplace, others
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: "전체"
        case .residence: "거주지"
        case .workplace: "직장"
        case .others: "기타"
        }
    }
}

struct OnePageView: View {
    
    // MARK: - Dependencies
    
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Properties
    
    @State private var suspectImage: Image? = nil
    @State private var selection: Category = .residence
    
    // 샘플 카테고리별 개수
    private let counts: [Category: Int] = [
        .all: 16, .residence: 2, .workplace: 1, .others: 13
    ]
    
    // 샘플 카드 데이터
    private var items: [LocationItem] {
        switch selection {
        case .all, .residence:
            return [
                .init(icon: "house.fill", tint: .gray,     title: "주민등록주소", subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .orange,   title: "실거주지",   subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .indigo,   title: "여자친구집", subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .gray,     title: "주민등록주소", subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .orange,   title: "실거주지",   subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .indigo,   title: "여자친구집", subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .gray,     title: "주민등록주소", subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .orange,   title: "실거주지",   subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .indigo,   title: "여자친구집", subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .gray,     title: "주민등록주소", subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .orange,   title: "실거주지",   subtitle: "상세주소가 들어갑니다"),
                .init(icon: "house.fill", tint: .indigo,   title: "여자친구집", subtitle: "상세주소가 들어갑니다")
            ]
        case .workplace:
            return [
                .init(icon: "briefcase.fill", tint: .blue, title: "직장", subtitle: "상세주소가 들어갑니다")
            ]
        case .others:
            return [
                .init(icon: "mappin.circle.fill", tint: .purple, title: "기타 장소", subtitle: "상세주소가 들어갑니다")
            ]
        }
    }
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FadingProfileImage(suspectImage: suspectImage)
                
                LazyVStack(
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {
                    Section(
                        header: OnePageStickyHeader(
                            suspectName: "피의자명",
                            crime: "범죄명",
                            selection: $selection
                        )
                    ) {
                        VStack(spacing: 12) {
                            ForEach(items) { item in
                                LocationCard(
                                    type: .icon(Image(.testHome)),
                                    title: item.title,
                                    description: item.subtitle
                                )
                                .setupAsButton(false)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 75)
                    }
                }
            }
        }
        .overlay(alignment: .topLeading) {
            HStack {
                DWGlassEffectCircleButton(
                    action: { coordinator.pop() },
                    icon: Image(.back)
                )
                .setupSize(44)
                .setupIconSize(18)
                .padding(.leading, 16)
                
                Spacer()
            }
            .safeAreaInset(edge: .top) {
                Color.white.ignoresSafeArea().frame(height: 0)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

// TODO: - 수정될 데이터 모델의 형태

private struct LocationItem: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
}

// MARK: - Extension Methods

extension OnePageView {}

// MARK: - Private Extension Methods

private extension OnePageView {}

// MARK: - Preview

#Preview {
    OnePageView()
        .environment(AppCoordinator())
}
