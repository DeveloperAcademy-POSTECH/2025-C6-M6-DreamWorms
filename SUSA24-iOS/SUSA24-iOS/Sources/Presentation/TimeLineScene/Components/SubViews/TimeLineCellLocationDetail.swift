//
//  TimeLineCellLocationDetail.swift
//  SUSA24-iOS
//
//  Created by Demian Yoo on 11/4/25.
//

import SwiftUI

// MARK: - View

/// 타임라인 위치 정보 셀 컴포넌트
///
/// 특정 위치에서의 체류 시간 정보를 표시합니다.
/// - 제목: "기지국 위치 정보"  (Localizable)
/// - 시간: 시작 시간 ~ 종료 시간 (예: "01:44 PM - 02:49 PM ")
///
/// # 사용예시
/// ```swift
///  //CoreData에서 가져온 Date 사용
///  TimeLineCellLocationDetail(
///     title: String(localized: .localtionInfo),
///     startTime: location.startTime,
///     endTime: location.endTime
///     )
///    ```
///
struct TimeLineCellLocationDetail: View {
    let caseTitle: String
    let startTime: Date
    let endTime: Date?

    var timeFormat: String = "hh:mm a" // 12시간 형식 ( 01:44 PM )

    /// 시간 범위 텍스트
    private var timeRangeText: String {
        let start = startTime.formatted(timeFormat)

        if let endTime {
            let end = endTime.formatted(timeFormat)
            // Localizable 포맷 사용
            return String(localized: .timeRangeFormat(
                start: start,
                end: end
            ))
        } else {
            return start
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 제목
            Text(caseTitle)
                .font(.titleSemiBold16)
                .foregroundStyle(.labelNormal)

            // 시간 범위
            Text(timeRangeText)
                .font(.numberRegular15)
                .foregroundStyle(.labelAlternative)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
    }
}

// MARK: - Progressive Disclosure

extension TimeLineCellLocationDetail {
    /// 시간 포맷을 설정합니다.
    ///
    /// - Parameter format: DateFormatter 형식 문자열
    ///     - "hh:mm a" : 01:44 PM ( 12시간 형식 )
    ///     - "HH:mm" : 13:44 (24시간 형식)
    @discardableResult
    func setupTimeFormat(_ format: String) -> Self {
        var v = self
        v.timeFormat = format
        return v
    }
}

//// MARK: - Preview
//
// #Preview("Location Detail Cell - States") {
//    VStack(spacing: 20) {
//        // 12시간 형식 (기본)
//        VStack(alignment: .leading, spacing: 8) {
//            Text("12시간 형식 (PM/AM)")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//
//            TimeLineCellLocationDetail(
//                caseTitle: "기지국 위치 정보",
//                startTime: Date().addingTimeInterval(-3600),  // 1시간 전
//                endTime: Date()
//            )
//            .padding(16)
//            .background(.mainAlternative)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//
//        Divider()
//
//        // 24시간 형식
//        VStack(alignment: .leading, spacing: 8) {
//            Text("24시간 형식")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//
//            TimeLineCellLocationDetail(
//                caseTitle: "기지국 위치 정보",
//                startTime: Date().addingTimeInterval(-7200),  // 2시간 전
//                endTime: Date().addingTimeInterval(-3600)     // 1시간 전
//            )
//            .setupTimeFormat("HH:mm")  // 24시간 형식
//            .padding(16)
//            .background(.mainAlternative)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//
//        Divider()
//
//        // 실제 사용 예시 (리스트에서)
//        VStack(alignment: .leading, spacing: 8) {
//            Text("리스트에서 사용")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//
//            LocationDetailListPreview()
//        }
//    }
//    .padding(16)
// }
//
//// MARK: - Preview Helpers
//
// private struct LocationDetailListPreview: View {
//    // CoreData에서 가져온 데이터 시뮬레이션
//    let mockLocations: [(Date, Date)] = [
//        (Date().addingTimeInterval(-7200), Date().addingTimeInterval(-5400)),  // 2시간 전 ~ 1.5시간 전
//        (Date().addingTimeInterval(-3600), Date().addingTimeInterval(-1800)),  // 1시간 전 ~ 30분 전
//        (Date().addingTimeInterval(-900), Date())                               // 15분 전 ~ 현재
//    ]
//
//    var body: some View {
//        VStack(spacing: 12) {
//            ForEach(mockLocations.indices, id: \.self) { index in
//                HStack(spacing: 12) {
//                    // 인디케이터
//                    Circle()
//                        .fill(.primaryNormal)
//                        .frame(width: 8, height: 8)
//
//                    // 위치 정보
//                    TimeLineCellLocationDetail(
//                        caseTitle: "기지국 위치 정보",
//                        startTime: mockLocations[index].0,
//                        endTime: mockLocations[index].1
//                    )
//                }
//                .padding(12)
//                .background(.mainAlternative)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
//        }
//    }
// }
