//  StayTimelineItem.swift

import SwiftUI

/// 체류 타임라인 아이템
///
/// 역할: 세로선 + 점 + 위치/시간 정보 조합
struct StayTimelineItem: View {
    let stay: LocationStay
    let isLast: Bool
    
    var body: some View {
        ItemRow(
            stay: stay,
            isLast: isLast
        )
    }
}

// MARK: - Item Row

private struct ItemRow: View {
    let stay: LocationStay
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VerticalTimeline(isLast: isLast)
            
            StayContent(stay: stay)
            
            Spacer()
        }
    }
}

// MARK: - Stay Content

/// 체류 정보 컨텐츠
private struct StayContent: View {
    let stay: LocationStay
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 주소
            Text(stay.address)
                .font(.pretendardMedium(size: 15))
                .foregroundStyle(Color.black22)
            
            // 시간 범위
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray8B)
                
                Text(timeRangeText)
                    .font(.pretendardRegular(size: 13))
                    .foregroundStyle(Color.gray8B)
                
                // 진행 중 표시
                if stay.isOngoing {
                    OngoingBadge()
                }
            }
        }
    }
    
    private var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let start = formatter.string(from: stay.startTime).uppercased()
        let end = formatter.string(from: stay.endTime).uppercased()
        
        return "\(start) - \(end)"
    }
}

// MARK: - Ongoing Badge

/// 진행 중 배지
private struct OngoingBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
            
            Text("진행중")
                .font(.pretendardMedium(size: 11))
                .foregroundStyle(Color.green)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StayTimelineItem(
            stay: LocationStay(
                address: "서울특별시 관악구 남부순환로 1812",
                startTime: Date().addingTimeInterval(-7200),
                endTime: Date().addingTimeInterval(-3600),
                locations: []
            ),
            isLast: false
        )
        
        StayTimelineItem(
            stay: LocationStay(
                address: "부산 강서구 지사동",
                startTime: Date().addingTimeInterval(-3600),
                endTime: Date(),
                locations: []
            ),
            isLast: true
        )
    }
    .padding()
}
