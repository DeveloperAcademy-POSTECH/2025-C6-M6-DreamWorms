//
//  View+HapticFeedback.swift
//  DreamWorms-iOS
//
//  Created by mini on 10/18/25.
//

import SwiftUI

extension View {
    /// Light 수준의 햅틱 발생시키는 메서드
    func triggerLightHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    /// Medium 수준의 햅틱 발생시키는 메서드
    func triggerMediumHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    /// Heavy 수준의 햅틱 발생시키는 메서드
    func triggerHeavyHapticFeedback() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
