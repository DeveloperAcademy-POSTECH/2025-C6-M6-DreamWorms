//
//  PlaceInfoSheet.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/6/25.
//

import SwiftUI

/// 장소 정보를 표시하는 바텀 시트
struct PlaceInfoSheet: View {
    let placeInfo: PlaceInfo
    let isLoading: Bool
    let onClose: () -> Void
        
    var body: some View {
        if isLoading {
            CircleProgressView()
                .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading) {
                PlaceInfoSheetHeader(
                    title: placeInfo.title,
                    onClose: onClose
                )
                
                PlaceInfoSheetContent(placeInfo: placeInfo)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 18)
        }
    }
}

// MARK: - SubView

// MARK: - PlaceInfoSheetHeader

/// 타이틀과 닫기 버튼을 표시하는 헤더
struct PlaceInfoSheetHeader: View {
    let title: String
    let onClose: () -> Void
    
    let circleWidth: CGFloat = 19
    let circleHeight: CGFloat = 16
    let headerSize: CGFloat = 36
    let horizontalPadding: CGFloat = 16
    let topPadding: CGFloat = 2
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: circleWidth, height: circleHeight)
                .foregroundStyle(.clear)
            
            Spacer()
            
            Text(title)
                .font(.titleSemiBold20)
                .foregroundStyle(.labelNormal)
            
            Spacer()
            
            DWGlassEffectCircleButton(
                image: Image(.xmark),
                action: onClose
            )
            .setupSize(headerSize)
            .setupIconSize(width: circleWidth, height: circleHeight)
            .setupIconColor(.labelNeutral)
            .setupbuttonBackgroundColor(.labelAssistive)
            .setupInteractiveEffect(false)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }
}

// MARK: - PlaceBasicInfo

/// 레이블과 값을 표시하는 행
struct PlaceBasicInfo: View {
    let label: String
    let value: String
    
    let landAddressSpacing: CGFloat = 56
    let defaultSpacing: CGFloat = 12
    
    // 지번만 다른 spacing 값ㄴ
    var spacing: CGFloat {
        label == String(localized: .mapviewPlaceInfoJibun) ? landAddressSpacing : defaultSpacing
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Text(label)
                .font(.bodyMedium12)
                .foregroundStyle(.labelAlternative)
            
            Spacer()
            
            Text(value)
                .font(.bodyMedium14)
                .foregroundStyle(.labelNeutral)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - PlaceInfoSheetContent

/// 기본 정보 레이블과 섹션을 표시하는 컨텐츠
struct PlaceInfoSheetContent: View {
    let placeInfo: PlaceInfo
    
    let horizontalPadding: CGFloat = 16
    let sectionTopPadding: CGFloat = 16
    let rowTopPadding: CGFloat = 12
    let bottomPadding: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading) {
            // 기본 정보 레이블
            Text(String(localized: .mapviewPlaceInfoBasicInfo))
                .font(.bodyMedium16)
                .foregroundStyle(.labelNormal)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, sectionTopPadding)
            
            PlaceBasicInfo(
                label: String(localized: .mapviewPlaceInfoJibun),
                value: placeInfo.jibunAddress
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.top, rowTopPadding)
            
            // 도로명
            PlaceBasicInfo(
                label: String(localized: .mapviewPlaceInfoRoad),
                value: placeInfo.roadAddress
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.top, rowTopPadding)
            
            // 전화번호
            PlaceBasicInfo(
                label: String(localized: .mapviewPlaceInfoPhoneNumber),
                value: placeInfo.phoneNumber
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.top, rowTopPadding)
        }
        .padding(.bottom, bottomPadding)
    }
}

// MARK: - 프로그레스 뷰

struct CircleProgressView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}

// MARK: - Preview

//
// #Preview("전체 시트") {
//    struct PreviewWrapper: View {
//        @State private var isPresented = false
//
//        var body: some View {
//            Button("시트 열기") {
//                isPresented = true
//            }
//            .sheet(isPresented: $isPresented) {
//                PlaceInfoSheet(
//                    placeInfo: PlaceInfo(
//                        title: "장소명/건물명",
//                        landAddress: "대구광역시 달서구 상인동 1453-7 상인2동 주민센터",
//                        roadAddress: "대구광역시 달서구 상원로 27 상인2동주민 센터",
//                        phoneNumber: "010-9934-9349"
//                    ),
//                    isLoading: false,
//                    onClose: { isPresented = false }
//                )
//                .presentationDetents([.fraction(0.4)])
//                .presentationDragIndicator(.visible)
//            }
//        }
//    }
//
//    return PreviewWrapper()
// }
//
// #Preview("타이틀 + X 버튼") {
//    ZStack {
//        Color.gray.opacity(0.1)
//
//        VStack(spacing: 0) {
//            PlaceInfoSheetHeader(
//                title: "장소명/건물명",
//                onClose: {}
//            )
//
//            Spacer()
//        }
//    }
//    .frame(height: 200)
// }
//
// #Preview("기본 정보 섹션") {
//    ZStack {
//        Color.gray.opacity(0.1)
//
//        VStack(spacing: 0) {
//            PlaceInfoSheetContent(
//                placeInfo: PlaceInfo(
//                    title: "",
//                    landAddress: "대구광역시 달서구 상인동 1453-7 상인2동 주민센터",
//                    roadAddress: "대구광역시 달서구 상원로 27 상인2동주민 센터",
//                    phoneNumber: "010-9934-9349"
//                )
//            )
//
//            Spacer()
//        }
//    }
//    .frame(height: 300)
// }
