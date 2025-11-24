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
    let existingLocation: Location?
    let isLoading: Bool
    let onClose: () -> Void
    let onMemoTapped: () -> Void
    
    var hasPin: Bool {
        existingLocation != nil
    }
    
    var body: some View {
        if isLoading {
            CircleProgressView()
                .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                PlaceInfoSheetHeader(
                    hasPin: hasPin,
                    placeName: placeInfo.title,
                    locationTypeInt: existingLocation?.locationType,
                    locationColorType: existingLocation?.colorType,
                    title: hasPin ? (existingLocation?.title ?? placeInfo.title) : placeInfo.title,
                    onClose: onClose
                )
                .padding(.top, 18)
                
                if hasPin {
                    // 핀이 있을 때: 형사 노트 버튼 표시
                    MemoButton(
                        note: existingLocation?.note,
                        onTapped: onMemoTapped
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                }
                
                PlaceInfoSheetContent(placeInfo: placeInfo)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - SubView

// MARK: - PlaceInfoSheetHeader

/// 타이틀과 닫기 버튼을 표시하는 헤더
struct PlaceInfoSheetHeader: View {
    let hasPin: Bool
    
    let placeName: String
    
    let locationTypeInt: Int16?
    let locationColorType: Int16?
    
    var pinType: PinCategoryType? {
        guard let raw = locationTypeInt else { return nil }
        return PinCategoryType(raw)
    }
    
    var colorType: PinColorType? {
        guard let raw = locationColorType else { return nil }
        return PinColorType(raw)
    }
    
    let title: String
    let onClose: () -> Void
    
    let circleWidth: CGFloat = 19
    let circleHeight: CGFloat = 16
    let headerSize: CGFloat = 36
    let horizontalPadding: CGFloat = 16
    let topPadding: CGFloat = 0
    
    var body: some View {
        // TODO: 쒯, spacing 피그마 상 2인데 아무리 봐도 더 커보임. 추후 확인 필요
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Circle()
                    .frame(width: headerSize, height: headerSize)
                    .foregroundStyle(.clear)
                
                Spacer()
                
                Text(placeName)
                    .font(.titleSemiBold20)
                    .foregroundStyle(.labelNormal)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
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
            
            if hasPin, let pinType, let colorType {
                HStack(spacing: 2) {
                    pinType.icon
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: pinType.iconWidth, height: pinType.iconHeight)
                        .foregroundColor(colorType.color)
                    
                    Text(title)
                        .font(.bodyRegular14)
                        .foregroundColor(colorType.color)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }
}

// MARK: - MemoButton

/// 형사 노트 버튼
struct MemoButton: View {
    let note: String?
    let onTapped: () -> Void
    
    var body: some View {
        Button(action: onTapped) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    if let note, !note.isEmpty {
                        Text(note)
                            .font(.bodyRegular14)
                            .foregroundStyle(.labelNormal)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(.memoWriteTitle)
                            .font(.titleSemiBold16)
                            .foregroundStyle(.labelNormal)
                        
                        Text(.memoWritePlaceHolder)
                            .font(.bodyRegular14)
                            .foregroundStyle(.labelAlternative)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(.rightArrow)
                    .font(.system(size: 14))
                    .foregroundStyle(.labelNeutral)
            }
            .padding([.leading, .vertical], 20)
            .padding(.trailing, 16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.mainBackground)
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 12,
                        x: 0,
                        y: 2
                    )
            )
        }
    }
}

// MARK: - PlaceBasicInfo

/// 레이블과 값을 표시하는 행
struct PlaceBasicInfo: View {
    let label: String
    let value: String
    
    let landAddressSpacing: CGFloat = 56
    let defaultSpacing: CGFloat = 12
    
    // 지번만 다른 spacing 값
    var spacing: CGFloat {
        label == String(localized: .mapviewPlaceInfoJibun) ? landAddressSpacing : defaultSpacing
    }
    
    var body: some View {
        VStack(spacing: 6) {
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
            
            Rectangle()
                .fill(.labelAssistive)
                .frame(height: 0.5)
                .frame(maxWidth: .infinity)
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
        VStack(alignment: .leading, spacing: 0) {
            // 기본 정보 레이블
            Text(String(localized: .mapviewPlaceInfoBasicInfo))
                .font(.bodyMedium16)
                .foregroundStyle(.labelNormal)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, sectionTopPadding)
                .padding(.bottom, bottomPadding)
                        
            PlaceBasicInfo(
                label: String(localized: .mapviewPlaceInfoJibun),
                value: placeInfo.jibunAddress
            )
            .padding(.horizontal, horizontalPadding)
            
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

//#Preview("핀 없는 경우") {
//    struct PreviewWrapper: View {
//        @State private var isPresented = true
//
//        var body: some View {
//            Color.clear
//                .sheet(isPresented: $isPresented) {
//                    PlaceInfoSheet(
//                        placeInfo: PlaceInfo(
//                            title: "선택한 위치",
//                            jibunAddress: "대구광역시 달서구 상인동 1453-7 상인2동 주민센터",
//                            roadAddress: "대구광역시 달서구 상원로 27 상인2동주민 센터",
//                            phoneNumber: "010-9934-9349"
//                        ),
//                        existingLocation: nil,
//                        isLoading: false,
//                        onClose: { isPresented = false },
//                        onMemoTapped: {}
//                    )
//                    .presentationDetents([.fraction(0.4)])
//                    .presentationDragIndicator(.visible)
//                }
//        }
//    }
//
//    return PreviewWrapper()
//}
//
//#Preview("핀 있는 경우") {
//    struct PreviewWrapper: View {
//        @State private var isPresented = true
//
//        var body: some View {
//            Color.clear
//                .sheet(isPresented: $isPresented) {
//                    PlaceInfoSheet(
//                        placeInfo: PlaceInfo(
//                            title: "선택한 위치",
//                            jibunAddress: "대구광역시 달서구 상인동 1453-7",
//                            roadAddress: "대구광역시 달서구 상원로 27",
//                            phoneNumber: "010-9934-9349"
//                        ),
//                        existingLocation: Location(
//                            id: UUID(),
//                            address: "대구광역시 달서구 상인동 1453-7",
//                            title: "2동 304호",
//                            note: "CCTV 영상으로 판단했을 때 두 사람이 다툰 것으로 보임. 진술과 일치하지 않은 행동을 보이는 내용을 포착. 김호랭 형사에게 영상전달, 맘스터치 매장 직원 증언으로 단골이라고 함.",
//                            pointLatitude: 35.8563,
//                            pointLongitude: 128.5557,
//                            boxMinLatitude: nil,
//                            boxMinLongitude: nil,
//                            boxMaxLatitude: nil,
//                            boxMaxLongitude: nil,
//                            locationType: 3,
//                            colorType: 2,
//                            receivedAt: Date()
//                        ),
//                        isLoading: false,
//                        onClose: { isPresented = false },
//                        onMemoTapped: {}
//                    )
//                    .presentationDetents([.fraction(0.5)])
//                    .presentationDragIndicator(.visible)
//                }
//        }
//    }
//
//    return PreviewWrapper()
//}
//
//#Preview("핀 있는데 노트안쓴 경우") {
//    struct PreviewWrapper: View {
//        @State private var isPresented = true
//
//        var body: some View {
//            Color.clear
//                .sheet(isPresented: $isPresented) {
//                    PlaceInfoSheet(
//                        placeInfo: PlaceInfo(
//                            title: "선택한 위치",
//                            jibunAddress: "대구광역시 달서구 상인동 1453-7",
//                            roadAddress: "대구광역시 달서구 상원로 27",
//                            phoneNumber: "010-9934-9349"
//                        ),
//                        existingLocation: Location(
//                            id: UUID(),
//                            address: "대구광역시 달서구 상인동 1453-7",
//                            title: "2동 304호",
//                            note: "",
//                            pointLatitude: 35.8563,
//                            pointLongitude: 128.5557,
//                            boxMinLatitude: nil,
//                            boxMinLongitude: nil,
//                            boxMaxLatitude: nil,
//                            boxMaxLongitude: nil,
//                            locationType: 3,
//                            colorType: 2,
//                            receivedAt: Date()
//                        ),
//                        isLoading: false,
//                        onClose: { isPresented = false },
//                        onMemoTapped: {}
//                    )
//                    .presentationDetents([.fraction(0.5)])
//                    .presentationDragIndicator(.visible)
//                }
//        }
//    }
//
//    return PreviewWrapper()
//}
