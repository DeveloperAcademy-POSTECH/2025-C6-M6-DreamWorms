//
//  EvidenceSheetHeader.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

/// 바텀시트 헤더
///
/// 역할: 사건 정보 표시
struct EvidenceSheetHeader: View {
    // MARK: - Properties
    
    let caseName: String
    let suspectName: String
    let locationAmount: Int
    
    // MARK: - Body
    
    var body: some View {
        HeaderContainer(
            caseName: caseName,
            suspectName: suspectName,
            locationAmount: locationAmount
        )
    }
}

// MARK: - Header Container

private struct HeaderContainer: View {
    let caseName: String
    let suspectName: String
    let locationAmount: Int
    
    var body: some View {
        VStack(spacing: 4) {
            // 사건명 + 드롭다운
            CaseNameRow(caseName: caseName)
            
            // 피의자명 + 위치 개수
            CaseInfoRow(
                suspectName: suspectName,
                locationAmount: locationAmount
            )
            .padding(.top, 4)
        }
    }
}

// MARK: - Case Name Row

private struct CaseNameRow: View {
    let caseName: String
    
    var body: some View {
        ZStack {
            CaseTitleHeader(caseName: caseName)
            
            HStack {
                Spacer()
                HeaderDropdownButton()
                    .padding(.trailing, 16)
            }
        }
    }
}

// MARK: - Case Info Row
    
private struct CaseInfoRow: View {
    let suspectName: String
    let locationAmount: Int
        
    var body: some View {
        HStack(spacing: 6) {
            Spacer()
            CaseSuspectNameHeader(suspectName: suspectName)
            CaseDotHeader()
            CaseCellDataLocationCount(dataLocationCount: locationAmount)
            Spacer()
        }
    }
}

// MARK: - Preview
    
#Preview {
    EvidenceSheetHeader(
        caseName: "베트콩 소탕",
        suspectName: "왕꿈틀",
        locationAmount: 27
    )
}
