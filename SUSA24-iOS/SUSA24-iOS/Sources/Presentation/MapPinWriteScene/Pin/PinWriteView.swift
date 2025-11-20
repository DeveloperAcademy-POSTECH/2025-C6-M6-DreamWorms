//
//  PinWriteView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/13/25.
//

import SwiftUI

/// 핀 추가/수정 화면
struct PinWriteView: View {
    let placeInfo: PlaceInfo
    let coordinate: MapCoordinate?
    let existingLocation: Location?
    let caseId: UUID
    let isEditMode: Bool
    let onSave: (Location) -> Void
    let onCancel: () -> Void
    
    @State private var pinName: String = ""
    @State private var selectedColor: PinColorType = .black
    @State private var selectedCategory: PinCategoryType = .home
    @FocusState private var isPinNameFocused: Bool
    
    /// 유효성 검사: 한글자 이상, 20자 이하, 숫자/기호(이모지 제외) 불가
    private var isValidPinName: Bool {
        let trimmedName = pinName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName.count <= 20 else { return false }
        
        // 한글, 영문, 이모지만 허용
        let allowedCharacterSet = CharacterSet.letters
            .union(.whitespaces)
        
        // 숫자와 일반 기호 제거한 문자열
        let filtered = trimmedName.unicodeScalars.filter { scalar in
            allowedCharacterSet.contains(scalar) || scalar.properties.isEmoji
        }
        
        return String(String.UnicodeScalarView(filtered)) == trimmedName
    }
    
    var body: some View {
        VStack(spacing: 0) {
            PinWriteHeader(
                title: isEditMode ? String(localized: .pinModify) : String(localized: .pinAdd),
                isSaveEnabled: isValidPinName,
                onCloseTapped: onCancel,
                onSaveTapped: savePin
            )
            .padding(.top, 8)
            .padding(.bottom, 6)
            
            ScrollView {
                // 핀 이름 입력
                PinNameInputSection(
                    pinName: $pinName,
                    isValid: isValidPinName,
                    isFocused: $isPinNameFocused
                )
                .padding(.bottom, 24)
                
                // 핀 색상 선택
                PinColorSelectionSection(
                    selectedColor: $selectedColor
                )
                .padding(.bottom, 24)
                
                // 핀 아이콘 선택
                PinCategorySelectionSection(
                    selectedCategory: $selectedCategory,
                    selectedColor: selectedColor
                )
            }
            .padding(.bottom, 6)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
                        
            DWButton(
                isEnabled: .constant(isValidPinName),
                title: String(localized: .mapviewPinCreateButton)
            ) {
                savePin()
            }
        }
        .padding(.horizontal, 16)
        .background(.labelAssistive)
        .onAppear {
            if let location = existingLocation {
                pinName = location.title ?? ""
                selectedColor = PinColorType(rawValue: location.colorType) ?? .black
                selectedCategory = PinCategoryType(rawValue: location.locationType) ?? .home
            }
            isPinNameFocused = true
        }
    }
    
    private func savePin() {
        // 좌표 결정 로직
        let coordinateSource = existingLocation.map {
            MapCoordinate(latitude: $0.pointLatitude, longitude: $0.pointLongitude)
        } ?? coordinate
        // 좌표가 없는 예외 상황: 저장을 진행하지 않고 로그만 남깁니다.
        guard let coordinateSource else { return }
        
        let location = Location(
            id: existingLocation?.id ?? UUID(),
            address: placeInfo.jibunAddress,
            title: pinName.trimmingCharacters(in: .whitespacesAndNewlines),
            note: existingLocation?.note,
            pointLatitude: coordinateSource.latitude,
            pointLongitude: coordinateSource.longitude,
            boxMinLatitude: nil,
            boxMinLongitude: nil,
            boxMaxLatitude: nil,
            boxMaxLongitude: nil,
            locationType: selectedCategory.rawValue,
            colorType: selectedColor.rawValue,
            receivedAt: Date()
        )
        
        onSave(location)
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
    
    let allowedCharactersRegex = "^[가-힣A-Za-z0-9 \\-_/.,;:!?@#$%^&*()+=<>\\[\\]{}|~`]*$"
    
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
        
        // 1) 이모지 제거 + 허용 문자만 남기기
        filtered = filtered.unicodeScalars
            .filter { scalar in
                // 이모지 범위 차단
                !CharacterSet.emojis.contains(scalar) &&
                    // 허용 문자만 허용
                    CharacterSet.allowedCharacters.contains(scalar)
            }
            .map(String.init)
            .joined()
        
        // 2) 정규식으로 다시 한번 허용 문자만 필터링
        if filtered.range(of: allowedCharactersRegex, options: .regularExpression) == nil {
            filtered = String(filtered.unicodeScalars.filter {
                CharacterSet.allowedCharacters.contains($0)
            }.map(String.init).joined())
        }
        
        // 3) 최대 20자 제한
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
        .buttonStyle(.plain) // 깜빡이는 효과 제거 목적
    }
}

// MARK: - CharacterSet 확장

extension CharacterSet {
    /// 이모지 문자 영역 정의
    static let emojis: CharacterSet = {
        var set = CharacterSet()
        set.insert(charactersIn: "\u{1F600}" ... "\u{1F64F}") // Emoticons
        set.insert(charactersIn: "\u{1F300}" ... "\u{1F5FF}") // Misc Symbols and Pictographs
        set.insert(charactersIn: "\u{1F680}" ... "\u{1F6FF}") // Transport & Map Symbols
        set.insert(charactersIn: "\u{1F1E6}" ... "\u{1F1FF}") // Flags
        set.insert(charactersIn: "\u{2600}" ... "\u{26FF}") // Misc
        set.insert(charactersIn: "\u{2700}" ... "\u{27BF}") // Dingbats
        return set
    }()
    
    /// 허용 문자 (숫자/영문/한글/기본 기호)
    static let allowedCharacters: CharacterSet = {
        let letters = CharacterSet.letters
        let numbers = CharacterSet.decimalDigits
        let korean = CharacterSet(charactersIn: "가" ... "힣")
        let symbols = CharacterSet(charactersIn: "-_/.,;:!?@#$%^&*()+=<>[]{}|~` ")
        
        return letters
            .union(numbers)
            .union(korean)
            .union(symbols)
    }()
}

// MARK: - Preview

// #Preview("핀 추가") {
//    PinWriteView(
//        placeInfo: PlaceInfo(
//            title: "선택한 위치",
//            jibunAddress: "대구광역시 달서구 상인동 1453-7",
//            roadAddress: "대구광역시 달서구 상원로 27",
//            phoneNumber: "-"
//        ),
//        coordinate: MapCoordinate(latitude: 35.8563, longitude: 128.5557),
//        existingLocation: nil,
//        caseId: UUID(),
//        isEditMode: false,
//        onSave: { _ in },
//        onCancel: {}
//    )
// }
//
// #Preview("핀 수정") {
//    PinWriteView(
//        placeInfo: PlaceInfo(
//            title: "선택한 위치",
//            jibunAddress: "대구광역시 달서구 상인동 1453-7",
//            roadAddress: "대구광역시 달서구 상원로 27",
//            phoneNumber: "-"
//        ),
//        coordinate: MapCoordinate(latitude: 35.8563, longitude: 128.5557),
//        existingLocation: Location(
//            id: UUID(),
//            address: "대구광역시 달서구 상인동 1453-7",
//            title: "2동 304호",
//            note: nil,
//            pointLatitude: 35.8563,
//            pointLongitude: 128.5557,
//            boxMinLatitude: nil,
//            boxMinLongitude: nil,
//            boxMaxLatitude: nil,
//            boxMaxLongitude: nil,
//            locationType: 0,
//            colorType: 2,
//            receivedAt: Date()
//        ),
//        caseId: UUID(),
//        isEditMode: true,
//        onSave: { _ in },
//        onCancel: {}
//    )
// }
