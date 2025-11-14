//
//  CapturedPhoto.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

import Foundation
import UIKit

/// 촬영된 사진을 나타내는 struct
struct CapturedPhoto: Identifiable {
    let id: UUID
    let data: Data
    let timestamp: Date
    let thumbnail: UIImage?
}
