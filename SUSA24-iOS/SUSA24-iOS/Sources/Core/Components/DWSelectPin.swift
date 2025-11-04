//
//  DWDateSelctPin.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/4/25.
//

import SwiftUI

// MARK: - Chip State

/// 'DWTimeChip' 의 상태를 정의하는 열거형입니다.
enum DWSelectPinState: Equatable {
    /// 기본 ( 선택되지 않은 ) 상태입니다.
    case normal
    /// 선택된 상태입니다.
    case selected
    
    var backgroundColor: Color {
        switch self {
        case .normal: .mainBackground
        case .selected: .mainAlternative
        }
    }
    
    var textColor: Color {
        switch self {
        case .normal: .labelNeutral
        case .selected: .labelAlternative
        }
    }
    
    var borderColor: Color {
        switch self {
        case .normal: .labelCoolNormal
        case .selected: .clear
        }
    }
}

// MARK: - View

/// 시간 표시 칩 컴포넌트
///
/// 시간 필터링에 사용되는 캡슐 모양의 칩입니다.
/// - 기본 상태: 밝은 배경, 어두운 텍스트
/// - 선택 상태: 어두운 배경, 밝은 텍스트
///
/// # 사용예시
/// ```swift
/// // 기본 사용
/// DWTimeChip(
///     time: "14:30",
///     isSelected: false,
///     action: { print("Tapped") }
/// )
///
/// // 선택된 상태
/// @State private var selectedTime = "14:30"
///
/// DWTimeChip(
///     time: "14:30",
///     isSelected: selectedTime == "14:30",
///     action: { selectedTime = "14:30" }
/// )
/// ```
///
struct DWSelectPin: View {
    
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var contentPadding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
    
    private var currentState: DWSelectPinState {
        isSelected ? .selected : .normal
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.numberMedium16)
                .foregroundStyle(currentState.textColor)
                .padding(contentPadding)
                .background(currentState.backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(currentState.borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: isSelected)
    }
}

// MARK: - Progressive Disclosure

extension DWSelectPin {
    
    /// 칩 내부의 패딩을 설정합니다.
    ///
    ///   - Parameter insets: 내부 패딩 값
    @discardableResult
    func setupPadding(_ insets: EdgeInsets) -> Self {
        var v = self
        v.contentPadding = insets
        return v
    }
}

// MARK: - Preview

//#Preview("Time Chip - States") {
//    DWSelectPinPreview()
//}
//
//private struct DWSelectPinPreview: View {
//    @State private var selected = "10.30"
//
//    var body: some View {
//        HStack {
//            ForEach(["10.29","10.30","10.31"], id: \.self) { day in
//                DWSelectPin(
//                    text: day,
//                    isSelected: selected == day,
//                    action: { selected = day }
//                )
//            }
//        }
//        .padding()
//    }
//}
