import SwiftUI

/// 지도 위에 올라가는 “증거 정보” 바텀시트 컨테이너
/// - 역할: Small/Medium/Large 단계에 따른 레이아웃 골격만 제공
struct EvidenceBottomSheet: View {
    @Binding var currentDetent: PresentationDetent

    // 화면에 표시할 데이터
    let selectedCase: Case
    let totalLocationCount: Int
    let locationStays: [LocationStay]
//    let evidences: [Evidence]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 배경
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // 1) 헤더 (항상 노출)
                EvidenceSheetHeader(
                    caseName: selectedCase.name,
                    suspectName: selectedCase.suspectName,
                    locationAmount: totalLocationCount,
                    showDropdown: currentDetent == .large
                )
                .padding(.vertical, 14)
                
                Divider()
                // 2) 탭바 (항상 노출)
                EvidenceTabBar()
                    .padding(.vertical, 5)
                Divider()

                // 3) Medium / Large 에서만 추가 콘텐츠 노출
                if currentDetent != .small {
                    DateFilterBar()
                    Divider()

                    LocationStayList(locationStays: locationStays)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Small") {
    EvidenceBottomSheet(
        currentDetent: .constant(.small),
        selectedCase: Case(name: "베트콩 소탕", number: "2024-001", suspectName: "왕꿈틀"),
        totalLocationCount: 5,
        locationStays: []
    )
}

#Preview("Medium") {
    EvidenceBottomSheet(
        currentDetent: .constant(.medium),
        selectedCase: Case(name: "베트콩 소탕", number: "2024-001", suspectName: "왕꿈틀"),
        totalLocationCount: 5,
        locationStays: [] // Mock 데이터는 실제 데이터로 대체
    )
}
