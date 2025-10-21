//
//  MapControlPanel.swift
//  DreamWorms-iOS
//
//  Created by taeni on 10/19/25.
//

import SwiftUI

struct MapControlPanel: View {
    @Binding var showFrequency: Bool
    @Binding var showCircle: Bool
    
    var isClusteringEnabled: Bool
    var onToggleFrequency: () -> Void
    var onToggleCircle: () -> Void
    var onRefresh: () -> Void
    var onCamera: () -> Void

    var body: some View {
        VStack {
            DWCircleToggleButton(
                title: String(localized: .mapFrequency),
                isOn: $showFrequency,
                action: onToggleFrequency
            )
            
            DWCircleToggleButton(
                title: String(localized: .mapRadiusOverlay),
                isOn: $showCircle,
                action: onToggleCircle
            )
            
            DWCircleToggleButton(
                title: String(localized: .mapRecent),
                isOn: .constant(false),
                action: onRefresh
            )
            
            Spacer()
            
            DWCircleToggleButton(
                title: "카메라",
                isOn: .constant(true),
                action: onCamera
            )
            .padding(.bottom, 200)
        }
        .padding(.top, 124)
        .padding(.trailing, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}
