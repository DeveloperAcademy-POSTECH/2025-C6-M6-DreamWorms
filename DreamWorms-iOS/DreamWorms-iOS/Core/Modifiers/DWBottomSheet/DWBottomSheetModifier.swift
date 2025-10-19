//
//  DWBottomSheetModifier.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

// MARK: - BottomSheet ViewModifier

/// DreamWorms 커스텀 바텀시트 Modifier
///
/// 지도 위에 표시되는 증거 정보 바텀시트를 구현합니다.
///
/// - Important: iOS 16.4+ 필요
///
/// - Reference:
///   - [Apple HIG - Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
///   - [SK Devocean](https://devocean.sk.com/blog/techBoardDetail.do?ID=166992)

struct DWBottomSheetModifier<SheetContent: View>: ViewModifier {
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @Binding var detent: PresentationDetent
    
    let content: () -> SheetContent
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                self.content()
                    .presentationDetents(
                        DWBottomSheetConfiguration.supportedDetents,
                        selection: $detent
                    )
                    .presentationBackgroundInteraction(
                        DWBottomSheetConfiguration.backgroundInteraction
                    )
                    .presentationDragIndicator(
                        DWBottomSheetConfiguration.shouldShowDragIndicator(for: detent)
                            ? .visible
                            : .hidden
                    )
                    .presentationCornerRadius(
                        DWBottomSheetConfiguration.defaultCornerRadius
                    )
                    .interactiveDismissDisabled(true)
            }
    }
}

// MARK: - View Extension

extension View {
    /// DreamWorms 커스텀 바텀시트를 표시합니다
    ///
    /// - Parameters:
    ///   - isPresented: 바텀시트 표시 여부
    ///   - detent: 현재 높이 상태 (small/medium/large)
    ///   - content: 바텀시트에 표시할 SubView
    ///
    /// - Note:
    ///   - Small: 배경 터치 가능, 드래그로 닫기 불가
    ///   - Medium: 배경 터치 가능, 드래그로 Small 전환
    ///   - Large: 배경 터치 불가, 드래그 핸들 숨김
    ///
    func dreamwormsBottomSheet(
        isPresented: Binding<Bool>,
        detent: Binding<PresentationDetent>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            DWBottomSheetModifier(
                isPresented: isPresented,
                detent: detent,
                content: content
            )
        )
    }
}
