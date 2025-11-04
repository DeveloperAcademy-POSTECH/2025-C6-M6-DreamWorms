//
//  TimeLineDetail.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// 타임라인 상세 정보 셀 컴포넌트
///
/// 타임라인 리스트에서 사용되는 완전한 셀입니다.
/// - 왼쪽: 방문 빈도에 따른 색상 막대 ( TimeLineColorStick)
/// - 오른쪽: 위치 정보 및 시간 범위 (TimeLineCellLocationDetail)
///
/// #사용예시
///  ```swift
///  // CoreData에서 가져온 데이터
///  TimeLineDetail(
///     state: .top1,
///     title: location.title,
///     startTime: location.startTime,
///     endTime: location.endTime,
///     isLast: index == location.count - 1,
///     onTap: {print("Tapped")
/// )
/// ```
struct TimeLineDetail: View {
    let state: TimeLineColorStickState
    let caseTitle: String
    let startTime: Date
    let endTime: Date
    let isLast: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                // 왼쪽: 색상 막대
                TimeLineColorStick(
                    state: state,
                    isLast: isLast
                )
                
                // 오른쪽: 위치 정보
                TimeLineCellLocationDetail(
                    caseTitle: caseTitle,
                    startTime: startTime,
                    endTime: endTime
                )

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

//// MARK: - Preview
//
//#Preview("Timeline Detail - States") {
//    ScrollView {
//        VStack(spacing: 0) {
//            Text("Top 1 (가장 많이 방문)")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 16)
//                .padding(.top, 16)
//                .padding(.bottom, 8)
//            
//            TimeLineDetail(
//                state: .top1,
//                caseTitle: "대구 청테이프",
//                startTime: Date().addingTimeInterval(-7200),
//                endTime: Date().addingTimeInterval(-5400),
//                isLast: false,  // ⭐️ 추가
//                onTap: { print("Tapped Top1") }
//            )
//            .padding(.vertical, 8)
//            .padding(.horizontal, 16)
//            .background(.mainBackground)
//            
//            Divider()
//                .padding(.vertical, 8)
//            
//            Text("Top 2")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 16)
//                .padding(.bottom, 8)
//            
//            TimeLineDetail(
//                state: .top2,
//                caseTitle: "대구 수성구 범어동",
//                startTime: Date().addingTimeInterval(-5400),
//                endTime: Date().addingTimeInterval(-3600),
//                isLast: false,
//                onTap: { print("Tapped Top2") }
//            )
//            .padding(.vertical, 8)
//            .padding(.horizontal, 16)
//            .background(.mainBackground)
//            
//            Divider()
//                .padding(.vertical, 8)
//            
//            Text("Top 3")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 16)
//                .padding(.bottom, 8)
//            
//            TimeLineDetail(
//                state: .top3,
//                caseTitle: "대구 중구 동성로",
//                startTime: Date().addingTimeInterval(-3600),
//                endTime: Date().addingTimeInterval(-1800),
//                isLast: false,
//                onTap: { print("Tapped Top3") }
//            )
//            .padding(.vertical, 8)
//            .padding(.horizontal, 16)
//            .background(.mainBackground)
//            
//            Divider()
//                .padding(.vertical, 8)
//            
//            Text("Normal (마지막 셀 - 스틱 없음)")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 16)
//                .padding(.bottom, 8)
//            
//            TimeLineDetail(
//                state: .normal,
//                caseTitle: "대구 달서구 죽전동",
//                startTime: Date().addingTimeInterval(-1800),
//                endTime: Date(),
//                isLast: true,  // ⭐️ 마지막 셀!
//                onTap: { print("Tapped Normal") }
//            )
//            .padding(.vertical, 8)
//            .padding(.horizontal, 16)
//            .background(.mainBackground)
//        }
//    }
//    .background(.mainAlternative)
//}
//
//#Preview("Timeline Detail - List with Lazy") {
//    TimeLineDetailLazyListPreview()
//}
//
//// MARK: - Preview Helpers
//
//private struct TimeLineDetailLazyListPreview: View {
//    let mockData: [(TimeLineColorStickState, String, Date, Date)] = [
//        (.top1, "대구 청테이프", Date().addingTimeInterval(-10800), Date().addingTimeInterval(-9000)),
//        (.top1, "대구 청테이프", Date().addingTimeInterval(-7200), Date().addingTimeInterval(-5400)),
//        (.top2, "대구 수성구 범어동", Date().addingTimeInterval(-5400), Date().addingTimeInterval(-3600)),
//        (.top2, "대구 수성구 범어동", Date().addingTimeInterval(-3600), Date().addingTimeInterval(-2700)),
//        (.top3, "대구 중구 동성로", Date().addingTimeInterval(-2700), Date().addingTimeInterval(-1800)),
//        (.normal, "대구 달서구 죽전동", Date().addingTimeInterval(-1800), Date().addingTimeInterval(-900)),
//        (.normal, "대구 북구 칠성동", Date().addingTimeInterval(-900), Date())
//    ]
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 0) {  // ⭐️ LazyVStack 사용
//                ForEach(mockData.indices, id: \.self) { index in
//                    let data = mockData[index]
//                    
//                    TimeLineDetail(
//                        state: data.0,
//                        caseTitle: data.1,
//                        startTime: data.2,
//                        endTime: data.3,
//                        isLast: index == mockData.count - 1,  // ⭐️ 마지막 체크
//                        onTap: {
//                            print("Tapped: \(data.1)")
//                        }
//                    )
//                    
//                    
//                    
//                    
//                    if index < mockData.count - 1 {
//                    }
//                }
//            }
//        }
//        .background(.mainAlternative)
//    }
//}
