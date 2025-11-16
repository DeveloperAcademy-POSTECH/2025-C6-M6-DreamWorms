//
//  TrackingView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/17/25.
//

import SwiftUI

struct TrackingView: View {
    @Environment(AppCoordinator.self)
    private var coordinator
    
    // MARK: - Dependencies
    
    @State var timeLineStore: DWStore<TrackingFeature>

    // MARK: - Properties
    
    let caseID: UUID

    // MARK: - View

    var body: some View {
        Image(.icnTracking)
    }
}

// MARK: - Extension Methods

extension TrackingView {}

// MARK: - Private Extension Methods

private extension TrackingView {}

// MARK: - Preview

// #Preview {
//    TrackingView(caseID: UUID())
//        .environment(AppCoordinator())
// }
