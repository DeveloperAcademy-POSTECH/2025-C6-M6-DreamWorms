//
//  LensSmudgeOverlay.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/10/25.
//

import SwiftUI

// TODO: 기능 넣을지 말지에 따라서 정해질 예정
struct LensSmudgeOverlay: View {
    let smudge: LensSmudgeDetectionResult

    var body: some View {
        VStack {
            HStack {
                Text(smudge.statusText)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(smudge.confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(statusBackgroundColor(smudge.confidence))
            .cornerRadius(6)
            .padding(.horizontal, 16)
            .padding(.top, 120)
            
            Spacer()
        }
    }

    // color 임시
    func statusBackgroundColor(_ confidence: Float) -> Color {
        if confidence > 0.7 {
            return Color.red.opacity(0.6)
        } else if confidence > 0.4 {
            return Color.yellow.opacity(0.6)
        } else {
            return Color.green.opacity(0.6)
        }
    }
}
