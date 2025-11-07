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
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var store: DWStore<OnePageFeature>
    
    // MARK: - Properties
    
    @State private var suspectImage: Image? = nil
    var currentCaseID: UUID
    
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
                            selection: Binding(
                                get: { store.state.selection },
                                set: { store.send(.selectionChanged($0)) }
                            )
                        )
                    ) {
                        LazyVStack(spacing: 12) {
                            ForEach(store.state.items) { item in
                                LocationCard(
                                    type: .icon(LocationType(item.locationType).icon),
                                    title: item.title ?? "타이틀",
                                    description: item.address
                                )
                                .setupAsButton(false)
                                .setupIconBackgroundColor(PinColorType(item.colorType).color)
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
                    image: Image(.back),
                    action: { coordinator.pop() }
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
        .task {
            store.send(.onAppear(currentCaseID))
        }
    }
}

// MARK: - Extension Methods

extension OnePageView {}

// MARK: - Private Extension Methods

private extension OnePageView {}

// MARK: - Preview

// #Preview {
//    OnePageView(
//        store: DWStore(
//            initialState: OnePageFeature.State(),
//            reducer: OnePageFeature(repository: MockLocationRepository())
//        ),
//        currentCaseID: UUID()
//    )
//    .environment(AppCoordinator())
// }
