//
//  DWSheetSearchBar.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/5/25.
//

import SwiftUI

// MARK: - View

/// 검색 전용 텍스트 필드 컴포넌트
///
/// 시트(Sheet)에서 사용하기 위한 검색 입력 필드를 제공합니다.
/// - 오른쪽에 검색 아이콘 또는 작은 X 버튼이 표시됩니다.
/// - 활성 상태일 때는 외부에 큰 X 버튼을 조합하여 사용합니다.
/// - Liquid Glass 효과 없이 일반 배경을 사용합니다.
///
/// # 상태별 동작
/// - 내부 작은 X: 텍스트만 지움 (포커스 유지)
/// - 외부 큰 X: 검색 모드 종료 (포커스 해제 + 텍스트 초기화)
///
/// # 사용예시
/// ```swift
/// @State private var searchText = ""
/// @FocusState private var isSearchActive: Bool
///
/// HStack(spacing: 12) {
///     DWSearchBar(
///         text: $searchText,
///         isFocused: $isSearchActive
///     )
///     .setupPlaceholder("기지국 주소 검색")
///
///     if isSearchActive {
///         Button {
///             isSearchActive = false
///             searchText = ""
///         } label: {
///             Image(systemName: "xmark")
///                 .frame(width: 44, height: 44)
///                 .background(.mainAlternative)
///                 .clipShape(Circle())
///         }
///         .transition(.opacity)
///     }
/// }
/// .animation(.snappy, value: isSearchActive)
/// ```
struct DWSheetSearchBar: View {
    /// 바인딩된 텍스트 값입니다.
    @Binding var text: String
    /// 포커스 상태를 외부에서 제어하기 위한 바인딩입니다.
    @FocusState.Binding var isFocused: Bool
    
    /// 플레이스홀더 (필드 안에 표시됩니다)
    var placeholder: LocalizedStringResource?
    /// 텍스트 입력 영역의 패딩
    var contentPadding: EdgeInsets = .init(top: 11, leading: 16, bottom: 11, trailing: 12)
    
    /// 키보드 하단 리턴 버튼 타입
    var submitLabel: SubmitLabel = .search
    
    /// 리턴 버튼 탭 시 실행되는 액션
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder ?? "")
                    .font(.bodyMedium16)
                    .foregroundColor(.labelAssistive)
            )
            .focused($isFocused)
            .font(.bodyMedium16)
            .foregroundStyle(isFocused || !text.isEmpty ? .labelNormal : .labelAssistive)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .onSubmit { onSubmit?() }
            
            if isFocused, !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(.xmark)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(.labelAssistive)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            } else {
                Image(.search)
                    .font(.system(size: 20))
                    .foregroundStyle(.labelAssistive)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(contentPadding)
        .background(.mainAlternative)
        .clipShape(RoundedRectangle(cornerRadius: 100))
        .animation(.snappy(duration: 0.2), value: text)
        .animation(.snappy(duration: 0.2), value: isFocused)
    }
}

// MARK: - Progressive Disclosure

extension DWSheetSearchBar {
    
    /// 플레이스홀더 텍스트를 설정합니다.
    ///
    /// - Parameter text: 검색 바에 표시될 플레이스홀더
    @discardableResult
    func setupPlaceholder(_ text: LocalizedStringResource) -> Self {
        var v = self
        v.placeholder = text
        return v
    }
    
    /// 텍스트 필드 내부의 패딩을 설정합니다.
    ///
    /// - Parameter insets: 내부 패딩 값
    @discardableResult
    func setupPadding(_ insets: EdgeInsets) -> Self {
        var v = self
        v.contentPadding = insets
        return v
    }
    
    /// 키보드 리턴 버튼 동작을 설정합니다.
    ///
    /// - Parameters:
    ///   - submit: 리턴 키 타입 (`.search`, `.done` 등)
    ///   - onSubmit: 리턴 키를 눌렀을 때 실행할 액션
    @discardableResult
    func setupSubmit(
        _ submit: SubmitLabel = .search,
        onSubmit: (() -> Void)? = nil
    ) -> Self {
        var v = self
        v.submitLabel = submit
        v.onSubmit = onSubmit
        return v
    }
}

// MARK: - Preview

//#Preview("Search Bar - States") {
//    SearchBarStatePreview()
//}

// 미리보기 Helper
//private struct SearchBarStatePreview: View {
//    @State private var text = ""
//    @FocusState private var isFocused: Bool
//
//    var body: some View {
//        HStack {
//            DWSearchBar(
//                text: $text,
//                isFocused: $isFocused,
//            )
//            .setupPlaceholder("기지국 검색")
//
//            if isFocused {
//                Button {
//                    isFocused = false
//                } label: {
//                    Image(.xmark)
//                        .font(.system(size: 20, weight: .medium))
//                        .foregroundStyle(.labelNeutral)
//                        .frame(width: 44, height: 44)
//                        .background(.mainBackground)
//                        .clipShape(Circle())
//                }
//                .transition(.opacity)
//            }
//        }
//        .padding()
//        .animation(.snappy, value: isFocused)
//        .background(Color(.black))
//    }
//}
