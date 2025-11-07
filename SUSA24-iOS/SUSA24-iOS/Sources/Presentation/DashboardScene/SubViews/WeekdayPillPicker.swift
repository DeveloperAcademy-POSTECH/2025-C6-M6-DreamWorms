//
//  WeekdayPillPicker.swift
//  SUSA24-iOS
//
//  Created by mini on 11/4/25.
//

import SwiftUI

struct WeekdayPillPicker: View {
    @Binding var selection: Weekday

    var spacing: CGFloat = 6
    var size: CGFloat = 32

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Weekday.allCases) { day in
                let isSelected = (selection == day)
                weekdayFillButton(
                    weekday: day,
                    isSelected: isSelected
                ) {
                    withAnimation(.snappy) { selection = day }
                }
            }
        }
        .animation(.snappy, value: selection)
    }

    @ViewBuilder
    private func weekdayFillButton(
        weekday: Weekday,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? .primaryLight2 : .mainBackground)
                    .overlay(
                        Circle().stroke(isSelected ? .clear : .labelCoolNormal, lineWidth: 1)
                    )
                    .frame(width: size, height: size)

                Text(weekday.shortKR)
                    .font(.bodyMedium14)
                    .foregroundStyle(isSelected ? .primaryNormal : .labelNeutral)
            }
            .contentShape(.circle)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Extension Methods (Progressive Disclosure)

extension WeekdayPillPicker {
    @discardableResult
    func setupSpacing(_ value: CGFloat) -> Self {
        var v = self; v.spacing = value; return v
    }
    
    @discardableResult
    func setupSize(_ value: CGFloat) -> Self {
        var v = self; v.size = value; return v
    }
}
