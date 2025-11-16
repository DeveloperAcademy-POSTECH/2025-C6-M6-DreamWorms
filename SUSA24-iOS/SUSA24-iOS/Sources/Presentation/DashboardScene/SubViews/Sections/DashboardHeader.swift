//
//  DashboardHeader.swift
//  SUSA24-iOS
//
//  Created by mini on 11/8/25.
//

import SwiftUI

struct DashboardHeader: View {
    let title: String
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(makeStyledTitle(title))
                .kerning(-0.44)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 80)
                .padding(.bottom, 38)
                .padding(.horizontal, 16)
        }
        .overlay(alignment: .topLeading) {
            HStack {
                DWGlassEffectCircleButton(
                    image: Image(.back),
                    action: onBack
                )
                .setupSize(44)
                .setupIconSize(18)
                .padding(.leading, 16)
                
                Spacer()
            }
            .safeAreaInset(edge: .top) {
                Color.white.ignoresSafeArea().frame(height: 0)
            }
        }
    }
}

private extension DashboardHeader {
    /// DashboardHeader 전용
    /// 특정 스타일에 대해서 다른 폰트와 다른 색상을 적용하기 위한 Extension 메서드
    func makeStyledTitle(_ title: String) -> AttributedString {
        var attributed = AttributedString(title)
        attributed.font = .titleSemiBold22
        attributed.foregroundColor = .labelNormal
        
        // 공통 하이라이트 적용 함수
        func highlight(_ substring: String) {
            if let range = attributed.range(of: substring) {
                attributed[range].foregroundColor = .primaryNormal
                attributed[range].font = .numberSemiBold23
            }
        }
        
        // "체류시간 1위" "방문빈도 1위" 하이라이트
        highlight("체류시간 1위")
        highlight("방문빈도 1위")
        
        // 시간 패턴: "오전 11시 22분-오후 12시 33분"
        if let range = attributed.range(
            of: #"(오전|오후)\s?\d+시(\s?\d+분)?-\s?(오전|오후)\s?\d+시(\s?\d+분)?"#,
            options: .regularExpression
        ) {
            attributed[range].foregroundColor = .primaryNormal
            attributed[range].font = .numberSemiBold23
        }
        
        // 날짜 패턴: "10월 27일 수요일"
        if let range = attributed.range(
            of: #"\d+월\s\d+일\s[가-힣]+"#,
            options: .regularExpression
        ) {
            attributed[range].foregroundColor = .primaryNormal
            attributed[range].font = .numberSemiBold23
        }
        
        return attributed
    }
}

// #Preview {
//    DashboardHeader(title: String(localized: .testAnalyze), onBack: {})
// }
