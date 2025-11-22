//
//  PinWriteView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/13/25.
//

import SwiftUI

/// 핀 추가/수정 화면
struct PinWriteView: View {
    @State private var store: DWStore<PinWriteFeature>
    @FocusState private var isPinNameFocused: Bool
    let onCancel: () -> Void
    
    // MARK: - Initializer
    
    init(
        store: DWStore<PinWriteFeature>,
        onCancel: @escaping () -> Void
    ) {
        self._store = State(initialValue: store)
        self.onCancel = onCancel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            PinWriteHeader(
                title: store.state.isEditMode ? String(localized: .pinModify) : String(localized: .pinAdd),
                isSaveEnabled: store.state.isValidPinName,
                onCloseTapped: {
                    store.send(.cancelTapped)
                    onCancel()
                },
                onSaveTapped: {
                    store.send(.saveTapped)
                }
            )
            .padding(.top, 8)
            .padding(.bottom, 6)
            
            ScrollView {
                // 핀 이름 입력
                PinNameInputSection(
                    pinName: Binding(
                        get: { store.state.pinName },
                        set: { store.send(.updatePinName($0)) }
                    ),
                    isValid: store.state.isValidPinName,
                    isFocused: $isPinNameFocused
                )
                .padding(.bottom, 24)
                
                // 핀 색상 선택
                PinColorSelectionSection(
                    selectedColor: Binding(
                        get: { store.state.selectedColor },
                        set: { store.send(.selectColor($0)) }
                    )
                )
                .padding(.bottom, 24)
                
                // 핀 아이콘 선택
                PinCategorySelectionSection(
                    selectedCategory: Binding(
                        get: { store.state.selectedCategory },
                        set: { store.send(.selectCategory($0)) }
                    ),
                    selectedColor: store.state.selectedColor
                )
            }
            .padding(.bottom, 6)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
                        
            DWButton(
                isEnabled: .constant(store.state.isValidPinName),
                title: String(localized: .mapviewPinCreateButton)
            ) {
                store.send(.saveTapped)
            }
        }
        .padding(.horizontal, 16)
        .background(.labelAssistive)
        .task {
            store.send(.onAppear)
            isPinNameFocused = true
        }
    }
}

// MARK: - SubViews

// MARK: - PinNameInputSection

struct PinNameInputSection: View {
    @Binding var pinName: String
    let isValid: Bool
    let isFocused: FocusState<Bool>.Binding
    
    var characterCount: Int {
        pinName.count
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                TextField(.pinWritePlaceHolder, text: $pinName)
                    .font(.bodyMedium14)
                    .foregroundStyle(.labelNormal)
                    .padding(.leading, 8)
                    .focused(isFocused)
                    .onChange(of: pinName) { _, newValue in
                        pinName = validateInput(newValue)
                    }
                
                if !pinName.isEmpty {
                    Button(action: { pinName = "" }) {
                        Image(.xmarkFill)
                            .foregroundStyle(.labelAssistive)
                    }
                    .padding(.trailing, 10)
                }
                
                HStack(spacing: 0) {
                    Text("\(characterCount)")
                        .font(.numberMedium12)
                        .foregroundStyle(.labelNormal)
                    Text(String(localized: .pinWirteLimitLength))
                        .font(.numberMedium12)
                        .foregroundStyle(.labelAlternative)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 18)
            .background(.mainAlternative)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
    
    private func validateInput(_ input: String) -> String {
        var filtered = input
        
        // 1) 이모지 완전 제거 - 모든 방법 동원
        filtered = filtered.unicodeScalars
            .filter { scalar in
                // Emoji 속성 체크
                if scalar.properties.isEmoji {
                    return false
                }
                // Emoji Presentation 체크
                if scalar.properties.isEmojiPresentation {
                    return false
                }
                // 알려진 이모지 범위 체크
                if CharacterSet.emojis.contains(scalar) {
                    return false
                }
                // Variation Selector (이모지 스타일 선택자) 제거
                if (0xFE00 ... 0xFE0F).contains(scalar.value) {
                    return false
                }
                // Zero Width Joiner (이모지 결합용) 제거
                if scalar.value == 0x200D {
                    return false
                }
                return true
            }
            .map(String.init)
            .joined()
        
        // 2) 최대 20자 제한
        if filtered.count > 20 {
            filtered = String(filtered.prefix(20))
        }
        
        return filtered
    }
}

// MARK: - PinColorSelectionSection

struct PinColorSelectionSection: View {
    @Binding var selectedColor: PinColorType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(.pinWriteColorSelect)
                .font(.titleSemiBold14)
                .foregroundStyle(.labelNormal)
            
            HStack(spacing: 12) {
                ForEach(PinColorType.allCases, id: \.rawValue) { color in
                    ColorCircleButton(
                        color: color,
                        isSelected: selectedColor == color,
                        onTap: { selectedColor = color }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - ColorCircleButton

struct ColorCircleButton: View {
    let color: PinColorType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(color.color)
                .frame(
                    width: isSelected ? 42 : 36,
                    height: isSelected ? 42 : 36
                )
                .overlay {
                    if isSelected {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 3)
                        Circle()
                            .strokeBorder(.primaryNormal, lineWidth: 2)
                    }
                }
        }
        .frame(width: 42, height: 42)
    }
}

// MARK: - PinCategorySelectionSection

struct PinCategorySelectionSection: View {
    @Binding var selectedCategory: PinCategoryType
    let selectedColor: PinColorType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(.pinWriteIconSelect)
                .font(.titleSemiBold14)
                .foregroundStyle(.labelNormal)
            
            VStack(spacing: 4) {
                // Int16 기준으로 정렬 (home=0, work=1, custom=3)
                ForEach(
                    PinCategoryType.allCases.sorted(by: { $0.rawValue < $1.rawValue }),
                    id: \.rawValue
                ) { category in
                    CategoryCard(
                        category: category,
                        selectedColor: selectedColor,
                        isSelected: selectedCategory == category,
                        onTap: { selectedCategory = category }
                    )
                }
            }
        }
    }
}

// MARK: - CategoryCard

struct CategoryCard: View {
    let category: PinCategoryType
    let selectedColor: PinColorType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 8) {
                        category.icon
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(isSelected ? .primaryNormal : .labelNeutral)
                            .frame(width: category.iconWidth, height: category.iconHeight, alignment: .center)
                        
                        Text(category.text)
                            .font(.titleSemiBold16)
                            .foregroundStyle(isSelected ? .primaryNormal : .labelNeutral)
                    }
                    
                    Text(category.description)
                        .font(.bodyRegular14)
                        .foregroundStyle(.labelAlternative)
                }
                
                Spacer()
                
                Group {
                    if isSelected {
                        Image(.radioSelected)
                            .foregroundStyle(.primaryNormal)
                            .font(.system(size: 18))
                    } else {
                        Image(.radioDeselected)
                            .foregroundStyle(.labelNeutral)
                            .font(.system(size: 18))
                    }
                }
                .frame(alignment: .center)
            }
            .padding([.vertical, .trailing], 16)
            .padding(.leading, 20)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain) // 깜빡이는 효과 제거
    }
}

// MARK: - CharacterSet 확장

extension CharacterSet {
    /// 이모지 문자 영역 정의 - 완전 차단을 위한 모든 범위 포함
    static let emojis: CharacterSet = {
        var set = CharacterSet()
        
        // Emoticons (표정)
        set.insert(charactersIn: "\u{1F600}" ... "\u{1F64F}")
        
        // Miscellaneous Symbols and Pictographs (기호와 그림문자)
        set.insert(charactersIn: "\u{1F300}" ... "\u{1F5FF}")
        
        // Transport and Map Symbols (교통 및 지도 기호)
        set.insert(charactersIn: "\u{1F680}" ... "\u{1F6FF}")
        
        // Regional Indicator Symbols (국기)
        set.insert(charactersIn: "\u{1F1E6}" ... "\u{1F1FF}")
        
        // Supplemental Symbols and Pictographs
        set.insert(charactersIn: "\u{1F900}" ... "\u{1F9FF}")
        
        // Symbols and Pictographs Extended-A
        set.insert(charactersIn: "\u{1FA70}" ... "\u{1FAFF}")
        
        // Miscellaneous Symbols (기타 기호)
        set.insert(charactersIn: "\u{2600}" ... "\u{26FF}")
        
        // Dingbats
        set.insert(charactersIn: "\u{2700}" ... "\u{27BF}")
        
        // Enclosed Alphanumeric Supplement
        set.insert(charactersIn: "\u{1F100}" ... "\u{1F1FF}")
        
        // Enclosed Ideographic Supplement
        set.insert(charactersIn: "\u{1F200}" ... "\u{1F2FF}")
        
        // Playing Cards, Mahjong Tiles
        set.insert(charactersIn: "\u{1F0A0}" ... "\u{1F0FF}")
        
        // Miscellaneous Technical (일부 특수 기호)
        set.insert(charactersIn: "\u{2300}" ... "\u{23FF}")
        
        // Enclosed Characters (원 안의 문자)
        set.insert(charactersIn: "\u{3200}" ... "\u{32FF}")
        set.insert(charactersIn: "\u{3300}" ... "\u{33FF}")
        
        return set
    }()
}
