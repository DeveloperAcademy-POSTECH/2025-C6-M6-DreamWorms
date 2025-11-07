//
//  TimeLineView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/29/25.
//

import SwiftUI

struct TimeLineView: View {
    // MARK: - Dependencies
    
    @State private var store = DWStore(
        initialState: TimeLineFeature.State(),
        reducer: TimeLineFeature()
    )

    // MARK: - Properties
    
    private let caseTitle: String = "택시 상습추행"
    private let suspectName: String = "왕꾹"

    // MARK: - View

    var body: some View {
        ScrollView {
            Text(.testTimeline)
        }
        .padding(.top, 12)
    }
}

// MARK: - Extension Methods

extension TimeLineView {}

// MARK: - Private Extension Methods

private extension TimeLineView {}

// MARK: - Preview

#Preview {
    TimeLineView()
        .environment(AppCoordinator())
}
