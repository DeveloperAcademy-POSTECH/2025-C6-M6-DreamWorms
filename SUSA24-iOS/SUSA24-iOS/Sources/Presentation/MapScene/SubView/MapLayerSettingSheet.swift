//
//  MapLayerSettingSheet.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/9/25.
//

import SwiftUI

// MARK: - MapLayerSettingSheet

struct MapLayerSettingSheet: View {
    @Binding var selectedRange: CoverageRangeType
    @Binding var isCCTVEnabled: Bool
    @Binding var isBaseStationEnabled: Bool
    let onClose: () -> Void
        
    var body: some View {
        VStack {
            MapLayerSheetHeader(
                onClose: onClose
            )
            .padding(.bottom, 24)
            
            CoverageSection(
                selectedRange: $selectedRange
            )
            .padding(.bottom, 36)
            
            ToggleSection(
                isCCTVEnabled: $isCCTVEnabled,
                isBaseStationEnabled: $isBaseStationEnabled
            )
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.top, 18)
    }
}

// MARK: - SubViews

struct MapLayerSheetHeader: View {
    let onClose: () -> Void
    
    private let circleSize: CGFloat = 36
    private let horizontalPadding: CGFloat = 16
    private let topPadding: CGFloat = 2
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: circleSize, height: circleSize)
                .foregroundStyle(.clear)
            
            Spacer()
            
            Text(String(localized: .mapSetting))
                .font(.titleSemiBold16)
                .foregroundStyle(.labelNormal)
            
            Spacer()
            
            DWGlassEffectCircleButton(
                image: Image(.xmark),
                action: onClose
            )
            .setupSize(circleSize)
            .setupIconSize(width: 19, height: 16)
            .setupIconColor(.labelNeutral)
            .setupbuttonBackgroundColor(.mainBackground)
            .setupInteractiveEffect(false)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }
}

struct CoverageSection: View {
    @Binding var selectedRange: CoverageRangeType
    
    private let itemSize: CGFloat = 75
    private let itemSpacing: CGFloat = 12
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: .layerSettingCoverageTitle))
                .font(.titleSemiBold14)
                .foregroundStyle(.labelNormal)
                .padding(.leading, -8)
            
            HStack(spacing: itemSpacing) {
                ForEach(CoverageRangeType.allCases) { range in
                    CoverageItem(
                        range: range,
                        isSelected: range == selectedRange,
                        size: itemSize,
                        onSelect: { selectedRange = range }
                    )
                }
            }
        }
    }
}

struct CoverageItem: View {
    let range: CoverageRangeType
    let isSelected: Bool
    let size: CGFloat
    let onSelect: () -> Void
    
    private let cornerRadius: CGFloat = 10
    
    var body: some View {
        VStack(spacing: 6) {
            Button(action: onSelect) {
                Image(range.imageResource)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(isSelected ? .primaryNormal : .clear, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
            
            Text(range.title)
                .font(.numberRegular13)
                .foregroundStyle(.labelNormal)
                .frame(width: size)
        }
    }
}

struct ToggleSection: View {
    @Binding var isCCTVEnabled: Bool
    @Binding var isBaseStationEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: .layerSettingToggleTitle))
                .font(.titleSemiBold14)
                .foregroundStyle(.labelNormal)
            
            VStack(spacing: 0) {
                ToggleRow(
                    image: Image(.icnCctv),
                    title: String(localized: .cctv),
                    isOn: $isCCTVEnabled
                )
                .padding(.vertical, 12)
                
                Divider()
                
                ToggleRow(
                    image: Image(.icnCellStationFilter),
                    title: String(localized: .cellStation),
                    isOn: $isBaseStationEnabled,
                    iconTint: .labelAssistive
                )
                .padding(.vertical, 12)
            }
        }
    }
}

struct ToggleRow: View {
    let image: Image
    let title: String
    @Binding var isOn: Bool
    var iconTint: Color?
    
    private let spacing: CGFloat = 12
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: spacing) {
                MapLayerToggleIcon(
                    image: image,
                    tint: iconTint
                )
                
                Text(title)
                    .font(.bodyMedium14)
                    .foregroundStyle(.labelNormal)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .primaryNormal))
    }
}

struct MapLayerToggleIcon: View {
    let image: Image
    var tint: Color?
    
    private let size: CGFloat = 32
    
    var body: some View {
        RoundedRectangle(cornerRadius: size / 2)
            .fill(Color.mainAlternative)
            .frame(width: size, height: size)
            .overlay(
                image
                    .renderingMode(tint == nil ? .original : .template)
                    .foregroundStyle(tint ?? .primaryNormal)
            )
    }
}

// MARK: - Preview

// #Preview {
//    struct PreviewWrapper: View {
//        @State private var selectedRange: CoverageRangeType = .half
//        @State private var isCCTVEnabled = true
//        @State private var isBaseStationEnabled = false
//
//        var body: some View {
//            MapLayerSettingSheet(
//                selectedRange: $selectedRange,
//                isCCTVEnabled: $isCCTVEnabled,
//                isBaseStationEnabled: $isBaseStationEnabled,
//                onClose: {}
//            )
//            .frame(height: 420)
//        }
//    }
//
//    return PreviewWrapper()
// }
