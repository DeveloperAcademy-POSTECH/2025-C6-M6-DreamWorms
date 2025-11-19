//
//  ActivityView.swift
//  SUSA24-iOS
//
//  Created by mini on 11/19/25.
//

import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        vc.isModalInPresentation = true
        return vc
    }
    
    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
