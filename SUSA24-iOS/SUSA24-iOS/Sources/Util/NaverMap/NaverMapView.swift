//
//  NaverMapView.swift
//  SUSA24-iOS
//
//  Created by mini on 10/31/25.
//

import SwiftUI
import NMapsMap

struct NaverMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        return mapView
    }

    func updateUIView(_ uiView: NMFMapView, context: Context) {
    }
}
