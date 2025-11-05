//
//  TimeLineBottomSheetHeader.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// 타임라인 바텀시트의 헤더 컴포넌트
///
/// 바텀시트 상단에 표시되는 헤더로, 위치 정보와 통계를 보여줍니다.
/// - 드래그 인디케이터 포함
/// - 제목: 위치명 (예: "대구 청테이프")
/// - 왼쪽 통계: 사용자명 (예: "왕꿈틀")
/// - 오른쪽 통계: 위치 개수 (예: "27개")
///
struct TimeLineBottomSheetHeader: View {
    let title: String
    let suspectName: String
    let locationCount: Int
    
    var body: some View {
        VStack(spacing: 4) {
            // 제목
            Text(title)
                .font(.titleSemiBold20)
                .foregroundStyle(.labelNormal)
                .frame(maxWidth: .infinity, alignment: .center)
            // 통계 정보
            HStack(spacing: 0) {
                // 왼쪽: 사용자 정보
                HStack(spacing: 2) {
                    Image(.person)
                        .font(.system(size: 14))
                        .foregroundStyle(.labelAssistive)
                    
                    Text(suspectName)
                        .font(.bodyRegular14)
                        .foregroundStyle(.gray60)
                }
                if locationCount > 0 {
                    // 구분선
                    Circle()
                        .fill(.labelAssistive)
                        .frame(width: 3, height: 3)
                        .padding(.horizontal,6)
                    
                    // 오른쪽: 위치 개수
                    HStack(spacing: 2) {
                        Image(.icnFillPlace)
                            .font(.system(size: 16))
                            .foregroundStyle(.labelAlternative)
                        
                        Text("\(locationCount)개")
                            .font(.bodyRegular14)
                            .foregroundStyle(.gray60)
                    }
                }
            }
        }
    }
}

//// MARK: - Preview
//
//#Preview("TimeLine BottomSheet Header") {
//    VStack(spacing: 0) {
//        TimeLineBottomSheetHeader(
//            title: "대구 청테이프",
//            suspectName: "왕꿈틀",
//            locationCount: 27
//        )
//
//        Divider()
//
//        ScrollView {
//            VStack(spacing: 12) {
//                ForEach(0..<5) { _ in
//                    HStack {
//                        Circle()
//                            .fill(.primaryNormal)
//                            .frame(width: 8, height: 8)
//
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("기지국 위치 정보")
//                                .font(.bodyMedium14)
//                            Text("01:44 PM - 02:49 PM")
//                                .font(.captionRegular12)
//                                .foregroundStyle(.labelAlternative)
//                        }
//
//                        Spacer()
//                    }
//                    .padding(.horizontal, 16)
//                }
//            }
//            .padding(.vertical, 12)
//        }
//    }
//    .background(.mainBackground)
//}
//
