//
//  DWSelectPin.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// 선택 가능한 핀(칩) 컴포넌트
///
/// 선택 상태만 관리하며, Progressive Disclosure 패턴으로 모든 색상을 커스터마이즈할 수 있습니다.
///
/// # 기본 사용
/// ```swift
/// @State private var selected = "Option 1"
///
/// DWSelectPin(
///     text: "Option 1",
///     isSelected: selected == "Option 1",
///     action: { selected = "Option 1" }
/// )
/// ```
///
/// # 선택 색상 커스터마이즈
/// ```swift
/// DWSelectPin(text: "거주지", isSelected: true, action: {})
///     .selectedBackground(.blue)
///     .selectedText(.white)
///     .selectedBorder(.blue)
/// ```
///
/// # 기본 색상 커스터마이즈
/// ```swift
/// DWSelectPin(text: "거주지", isSelected: false, action: {})
///     .normalBackground(.gray.opacity(0.1))
///     .normalText(.black)
///     .normalBorder(.gray)
/// ```
///
/// # 한 번에 설정
/// ```swift
/// DWSelectPin(text: "거주지", isSelected: true, action: {})
///     .colors(
///         selected: (bg: .blue, text: .white, border: .clear),
///         normal: (bg: .white, text: .gray, border: .gray)
///     )
/// ```
struct DWSelectPin: View {
    
    // MARK: - Properties
    
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    // 선택 상태 색상
    var selectedBg: Color = .primaryLight2
    var selectedText: Color = .primaryNormal
    var selectedBorder: Color = .clear
    
    // 기본 상태 색상
    var normalBg: Color = .mainBackground
    var normalText: Color = .labelNeutral
    var normalBorder: Color = .labelCoolNormal
    
    // 레이아웃
    var contentPadding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.numberMedium16)
                .foregroundStyle(isSelected ? selectedText : normalText)
                .padding(contentPadding)
                .background(isSelected ? selectedBg : normalBg)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? selectedBorder : normalBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: isSelected)
    }
}

// MARK: - Progressive Disclosure

extension DWSelectPin {
    
    // MARK: - 선택 상태 (Selected State)
    
    /// 선택 시 배경색을 설정합니다.
    @discardableResult
    func selectedBackground(_ color: Color) -> Self {
        var v = self
        v.selectedBg = color
        return v
    }
    
    /// 선택 시 텍스트 색상을 설정합니다.
    @discardableResult
    func selectedText(_ color: Color) -> Self {
        var v = self
        v.selectedText = color
        return v
    }
    
    /// 선택 시 테두리 색상을 설정합니다.
    @discardableResult
    func selectedBorder(_ color: Color) -> Self {
        var v = self
        v.selectedBorder = color
        return v
    }
    
    // MARK: - 기본 상태 (Normal State)
    
    /// 기본 상태 배경색을 설정합니다.
    @discardableResult
    func normalBackground(_ color: Color) -> Self {
        var v = self
        v.normalBg = color
        return v
    }
    
    /// 기본 상태 텍스트 색상을 설정합니다.
    @discardableResult
    func normalText(_ color: Color) -> Self {
        var v = self
        v.normalText = color
        return v
    }
    
    /// 기본 상태 테두리 색상을 설정합니다.
    @discardableResult
    func normalBorder(_ color: Color) -> Self {
        var v = self
        v.normalBorder = color
        return v
    }
    
    // MARK: - 한 번에 설정 (Batch Setup)
    
    /// 모든 색상을 한 번에 설정합니다.
    ///
    /// - Parameters:
    ///   - selected: 선택 상태 색상 (배경, 텍스트, 테두리)
    ///   - normal: 기본 상태 색상 (배경, 텍스트, 테두리)
    @discardableResult
    func colors(
        selected: (bg: Color, text: Color, border: Color),
        normal: (bg: Color, text: Color, border: Color)
    ) -> Self {
        var v = self
        v.selectedBg = selected.bg
        v.selectedText = selected.text
        v.selectedBorder = selected.border
        v.normalBg = normal.bg
        v.normalText = normal.text
        v.normalBorder = normal.border
        return v
    }
    
    // MARK: - 레이아웃 (Layout)
    
    /// 칩 내부의 패딩을 설정합니다.
    @discardableResult
    func padding(_ insets: EdgeInsets) -> Self {
        var v = self
        v.contentPadding = insets
        return v
    }
}

//// MARK: - Preview
//
//#Preview("Select Pin - Default") {
//    DWSelectPinDefaultPreview()
//}
//
//#Preview("Select Pin - Custom") {
//    DWSelectPinCustomPreview()
//}
//
//#Preview("Select Pin - Real Use Case") {
//    DWSelectPinRealUseCasePreview()
//}
//
//// MARK: - Preview Helpers
//
//private struct DWSelectPinDefaultPreview: View {
//    @State private var selected = "10.30"
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("기본 스타일")
//                .font(.caption)
//                .bold()
//            
//            HStack(spacing: 12) {
//                ForEach(["10.29", "10.30", "10.31"], id: \.self) { day in
//                    DWSelectPin(
//                        text: day,
//                        isSelected: selected == day,
//                        action: { selected = day }
//                    )
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//private struct DWSelectPinCustomPreview: View {
//    @State private var selected1 = "Blue"
//    @State private var selected2 = "Red"
//    @State private var selected3 = "Green"
//    
//    var body: some View {
//        VStack(spacing: 32) {
//            // Blue
//            VStack(spacing: 16) {
//                Text("커스텀: 파랑")
//                    .font(.caption)
//                
//                HStack(spacing: 12) {
//                    ForEach(["Blue", "Sky", "Navy"], id: \.self) { item in
//                        DWSelectPin(
//                            text: item,
//                            isSelected: selected1 == item,
//                            action: { selected1 = item }
//                        )
//                        .selectedBackground(.blue)
//                        .selectedText(.white)
//                    }
//                }
//            }
//            
//            // Red
//            VStack(spacing: 16) {
//                Text("커스텀: 빨강")
//                    .font(.caption)
//                
//                HStack(spacing: 12) {
//                    ForEach(["Red", "Pink", "Rose"], id: \.self) { item in
//                        DWSelectPin(
//                            text: item,
//                            isSelected: selected2 == item,
//                            action: { selected2 = item }
//                        )
//                        .colors(
//                            selected: (bg: .red, text: .white, border: .clear),
//                            normal: (bg: .white, text: .gray, border: .gray)
//                        )
//                    }
//                }
//            }
//            
//            // Green
//            VStack(spacing: 16) {
//                Text("커스텀: 초록")
//                    .font(.caption)
//                
//                HStack(spacing: 12) {
//                    ForEach(["Green", "Mint", "Lime"], id: \.self) { item in
//                        DWSelectPin(
//                            text: item,
//                            isSelected: selected3 == item,
//                            action: { selected3 = item }
//                        )
//                        .selectedBackground(.green)
//                        .selectedText(.white)
//                        .normalBorder(.green.opacity(0.3))
//                        .padding(12)
//                    }
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//private struct DWSelectPinRealUseCasePreview: View {
//    @State private var selectedCategory = "거주지"
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("실제 사용 예시")
//                .font(.caption)
//                .bold()
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(["전체", "거주지", "직장", "기타"], id: \.self) { category in
//                        DWSelectPin(
//                            text: category,
//                            isSelected: selectedCategory == category,
//                            action: { selectedCategory = category }
//                        )
//                    }
//                }
//                .padding(.horizontal, 16)
//            }
//        }
//        .padding()
//    }
//}
